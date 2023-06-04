defmodule Assistant.Forum.Checker do
  @moduledoc false

  use TypedStruct
  use Assistant.I18n
  use Assistant.PubSub

  alias Assistant.EasyStore

  import Assistant.Forum.Client

  require Logger

  @pinned_forum_topics_key :pinned_forum_topics

  def run do
    case latest_topics(fn t -> t.pinned end) do
      {:ok, topics} ->
        check_and_notify(topics)

      {:error, reason} ->
        Logger.error("[forum] Request latest topics failed: #{inspect(reason: reason)}")
    end

    :ok
  end

  defp check_and_notify([]) do
    Logger.debug("[forum] No pinned topics found")
  end

  defp check_and_notify(topics) do
    old_topics = EasyStore.get(@pinned_forum_topics_key) || []

    new_topics =
      Enum.reject(topics, fn topic ->
        Enum.any?(old_topics, &(&1.id == topic.id))
      end)

    if Enum.empty?(new_topics) do
      Logger.debug("[forum] No new pinned topics found")
    else
      broadcast("forum", {:new_pinned_topics, {topics, new_topics}})
    end
  end
end
