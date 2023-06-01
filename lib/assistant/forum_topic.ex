defmodule Assistant.ForumTopic do
  @moduledoc false

  use TypedStruct
  use Assistant.I18n

  import Assistant.Helper

  require Logger

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

  defdelegate safe_html(text), to: Telegex.Tools
end
