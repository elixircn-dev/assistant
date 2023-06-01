defmodule AssistantBot.ForumChecker do
  @moduledoc false

  # TODO: 将此模块改为 PubSub 架构，仅负责消息的生产不再负责推送

  use TypedStruct
  use Assistant.I18n
  use AssistantBot.MessageCaller

  alias Assistant.EasyStore
  alias HTTPoison.Response

  require Logger

  @store_key :pinned_forum_topics

  defmodule Topic do
    @moduledoc false

    typedstruct do
      field :id, :integer
      field :title, String.t()
      field :slug, String.t()
      field :created_at, DateTime.t()
      field :pinned, boolean
      field :tags, [String.t()]
    end

    def from(topic) when not is_nil(:erlang.map_get("id", topic)) do
      created_at =
        case DateTime.from_iso8601(topic["created_at"]) do
          {:ok, dt, 0} ->
            dt

          {:error, reason} ->
            Logger.error(
              "[forum] Topic `created_at` field parse failed: #{inspect(reason: reason)}"
            )

            nil
        end

      %__MODULE__{
        id: topic["id"],
        title: topic["title"],
        slug: topic["slug"],
        created_at: created_at,
        pinned: topic["pinned"],
        tags: topic["tags"]
      }
    end

    def render_text(topic) do
      tags_text =
        Enum.map_join(topic.tags, " ", fn tag ->
          ~s|<a href="https://elixirforum.com/tag/#{tag}">##{safe_html(tag)}</a>|
        end)

      elapsed_time = elapsed_time(topic.created_at)

      tfooter = commands_text("新的置顶主题，发表于 %{elapsed_time}。", elapsed_time: elapsed_time)
      treading = commands_text("前往阅读")

      """
      <b><u>Elixir Forum</u></b>

      <b>#{safe_html(topic.title)}</b> #{tags_text}

      #{tfooter}<a href="https://elixirforum.com/t/#{topic.slug}/#{topic.id}">#{treading}</a>
      """
    end

    def elapsed_time(created_at) do
      dt_now = DateTime.utc_now()
      minutes = DateTime.diff(dt_now, created_at, :minute)

      if minutes < 60 do
        commands_text("%{count} 分钟之前", count: minutes)
      else
        hours = DateTime.diff(dt_now, created_at, :hour)

        if hours < 24 do
          commands_text("%{count} 小时之前", count: hours)
        else
          days = DateTime.diff(dt_now, created_at, :day)

          commands_text("%{count} 天之前", count: days)
        end
      end
    end

    defdelegate safe_html(text), to: Telegex.Tools
  end

  @endpoint "https://elixirforum.com/latest.json?ascending=false"

  def run do
    @endpoint |> HTTPoison.get() |> handle_response() |> check_and_notify()
  end

  @spec handle_response({:ok, Response.t()} | {:error, any}) :: [Topic.t()]
  defp handle_response({:ok, resp}) do
    json = Jason.decode!(resp.body)

    json["topic_list"]["topics"] |> Enum.map(&Topic.from/1) |> Enum.filter(& &1.pinned)
  end

  defp handle_response({:error, reason}) do
    Logger.error("[forum] Topics request failed: #{inspect(reason: reason)}")

    []
  end

  defp check_and_notify([]) do
    Logger.debug("[forum] No pinned topics found")
  end

  defp check_and_notify(topics) do
    old_topics = EasyStore.get(@store_key) || []

    new_topics =
      Enum.reject(topics, fn topic ->
        Enum.any?(old_topics, &(&1.id == topic.id))
      end)

    failed = notify(new_topics)

    # 缓存除推送失败的主题外的所有主题
    :ok = EasyStore.put(@store_key, topics -- failed)
  end

  # 向群组发送通知，返回发送失败的主题列表。
  @spec notify([Topic.t()]) :: [Topic.t()]
  defp notify([]) do
    Logger.debug("[forum] No new pinned topics found")

    []
  end

  defp notify(topics) do
    failed = topics |> Enum.map(&push/1) |> Enum.reject(&is_nil/1)

    Logger.debug("[forum] Successfully pushed #{length(topics) - length(failed)} topic(s)")

    failed
  end

  @send_opts [parse_mode: "HTML"]

  # 推送主题到群组，如果失败将返回原主题，成功则返回 `nil`。
  @spec push(Topic.t()) :: Topic.t() | nil
  defp push(topic) do
    chat_id = AssistantBot.config(:group_id)

    pin? = Enum.member?(topic.tags, "elixir-release")

    case send_text(chat_id, Topic.render_text(topic), @send_opts) do
      {:ok, %{message_id: message_id}} ->
        if pin?, do: Telegex.pin_chat_message(chat_id, message_id)

        nil

      {:error, reason} ->
        Logger.error("[forum] Send message failed: #{inspect(reason: reason)}", chat_id: chat_id)

        topic
    end
  end
end
