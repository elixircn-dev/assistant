defmodule AssistantBot.BroadcastCenter do
  @moduledoc false

  use GenServer
  use Assistant.PubSub
  use Assistant.I18n
  use AssistantBot.MessageCaller

  alias Assistant.{EasyStore, PushCounter}
  alias Assistant.Forum.Topic
  alias Assistant.HexPm.Package

  require Logger

  @pinned_forum_topics_key :pinned_forum_topics

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    :ok = subscribe("forum")
    :ok = subscribe("github")
    :ok = subscribe("hex_pm")

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

  @impl true
  def handle_info({:repo_release, {notification, subject}}, state) do
    # 推送到群组
    push_repo_release(notification, subject)

    {:noreply, state}
  end

  @impl true
  def handle_info({:pkg_publish, package}, state) do
    # 推送到群组
    push_pkg_publish(package)

    {:noreply, state}
  end

  @send_opts [parse_mode: "HTML"]

  # 推送主题到群组，如果失败将返回原主题，成功则返回 `nil`。
  @spec push_forum_topic(Topic.t()) :: Topic.t() | nil
  defp push_forum_topic(topic) do
    chat_id = AssistantBot.config(:group_id)

    pin? = Enum.member?(topic.tags, "elixir-release")

    text = Topic.render_message_text(:pinned, topic)

    case send_text(chat_id, text, @send_opts) do
      {:ok, %{message_id: message_id}} ->
        if pin?, do: Telegex.pin_chat_message(chat_id, message_id, disable_notification: true)

        nil

      {:error, reason} ->
        Logger.error("[forum] Send message failed: #{inspect(reason: reason)}", chat_id: chat_id)

        topic
    end
  end

  def push_repo_release(notification, subject) do
    alias Assistant.GitHub.Notification

    count_key = Notification.key(notification)
    push_count = PushCounter.get_count(count_key)

    Logger.debug("[github] Push counter: #{count_key}:#{push_count}")

    text = Notification.render_message_text(push_count, notification, subject)

    case send_text(AssistantBot.config(:group_id), text, parse_mode: "HTML", logging: true) do
      {:ok, _} ->
        # 自增推送计数，仅在推送成功时自增。
        :ok = PushCounter.increase(count_key)

      _ ->
        :error
    end
  end

  @spec push_pkg_publish(Package.t()) :: :ok
  def push_pkg_publish(package) do
    count_key = Package.key(package)
    push_count = PushCounter.get_count(count_key)

    Logger.debug("[hex_pm] Push counter: #{count_key}:#{push_count}")

    text = Package.render_message_text(push_count, package)

    case send_text(AssistantBot.config(:group_id), text, parse_mode: "HTML", logging: true) do
      {:ok, _} ->
        # 自增推送计数，仅在推送成功时自增。
        :ok = PushCounter.increase(count_key)

      _ ->
        :error
    end
  end
end
