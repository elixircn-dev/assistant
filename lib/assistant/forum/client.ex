defmodule Assistant.Forum.Client do
  @moduledoc false

  alias Assistant.Forum.Topic
  alias HTTPoison.Response

  require Logger

  @endpoint "https://elixirforum.com"

  @type rdata :: map

  @spec latest_topics :: {:ok, [Topic.t()]} | {:error, any}
  def latest_topics(filter_fun \\ fn _ -> true end) do
    case get("/latest.json?ascending=false") do
      {:ok, json} ->
        topics =
          json["topic_list"]["topics"] |> Enum.map(&Topic.from/1) |> Enum.filter(filter_fun)

        {:ok, topics}

      e ->
        e
    end
  end

  @spec get(String.t()) :: {:ok, rdata} | {:error, any}
  defp get(path) do
    "#{@endpoint}#{path}" |> HTTPoison.get() |> handle_response()
  end

  @spec handle_response({:ok, Response.t()}) :: {:ok, rdata} | {:error, any}
  defp handle_response({:ok, resp}) do
    json = Jason.decode!(resp.body)

    {:ok, json}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
