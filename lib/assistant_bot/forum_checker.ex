defmodule AssistantBot.ForumChecker do
  @moduledoc false

  # TODO: 将此模块改为 PubSub 架构，仅负责消息的生产不再负责推送

  use TypedStruct
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
              "Elixir Forum topic `created_at` field parse error.: #{inspect(reason: reason)}"
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

      """
      <b>#{safe_html(topic.title)}</b> #{tags_text}

      官方论坛置顶了新的主题帖！<a href="https://elixirforum.com/t/#{topic.slug}/#{topic.id}">前往阅读</a>
      """
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
    Logger.error("[forum] Topics request error: #{inspect(reason: reason)}")

    []
  end

  defp check_and_notify([]) do
    Logger.debug("[forum] No new topics found")
  end

  defp check_and_notify(topics) do
    old_topics = EasyStore.get(@store_key) || []

    new_topics =
      Enum.reject(topics, fn topic ->
        Enum.any?(old_topics, &(&1.id == topic.id))
      end)

    notify(new_topics)
  end

  defp notify([]), do: :ignored

  defp notify(topics) do
    successed = topics |> Enum.map(&send/1) |> Enum.reject(&is_nil/1)

    :ok = EasyStore.put(@store_key, successed)

    :ok
  end

  @send_opts [parse_mode: "HTML"]

  @spec send(Topic.t()) :: Topic.t() | nil
  defp send(topic) do
    chat_id = AssistantBot.config(:group_id)

    case send_text(chat_id, Topic.render_text(topic), @send_opts) do
      {:ok, _} ->
        topic

      {:error, reason} ->
        Logger.error("[forum] Send message error: #{inspect(reason: reason)}", chat_id: chat_id)

        nil
    end
  end
end
