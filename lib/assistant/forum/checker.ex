defmodule Assistant.Forum.Checker do
  @moduledoc false

  use TypedStruct
  use Assistant.I18n
  use Assistant.PubSub

  alias Assistant.EasyStore
  alias Assistant.Forum.Topic
  alias HTTPoison.Response

  require Logger

  @pinned_forum_topics_key :pinned_forum_topics

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
