defmodule AssistantBot.BroadcastCenter do
  @moduledoc false

  use GenServer
  use Assistant.PubSub
  use AssistantBot.MessageCaller

  alias Assistant.{ForumTopic, EasyStore}

  require Logger

  @pinned_forum_topics_key :pinned_forum_topics

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    :ok = subscribe("forum")
    :ok = subscribe("github")

    Logger.info("Broadcast center started")

    {:ok, state}
  end

  @impl true
  def handle_info({:new_pinned_topics, {topics, new_topics}}, state) do
    failed = new_topics |> Enum.map(&push_forum_topic/1) |> Enum.reject(&is_nil/1)

    Logger.debug("[forum] Successfully pushed #{length(new_topics) - length(failed)} topic(s)")

    # 缓存的主题列表是已置顶列表减去推送失败的主题列表
    :ok = EasyStore.put(@pinned_forum_topics_key, topics -- failed)

    {:noreply, state}
  end

  @send_opts [parse_mode: "HTML"]

  # 推送主题到群组，如果失败将返回原主题，成功则返回 `nil`。
  @spec push_forum_topic(ForumTopic.t()) :: ForumTopic.t() | nil
  defp push_forum_topic(topic) do
    chat_id = AssistantBot.config(:group_id)

    pin? = Enum.member?(topic.tags, "elixir-release")

    case send_text(chat_id, ForumTopic.render_text(topic), @send_opts) do
      {:ok, %{message_id: message_id}} ->
        if pin?, do: Telegex.pin_chat_message(chat_id, message_id)

        nil

      {:error, reason} ->
        Logger.error("[forum] Send message failed: #{inspect(reason: reason)}", chat_id: chat_id)

        topic
    end
  end
end
