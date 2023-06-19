defmodule Assistant.HexPm.ClientImpl do
  @moduledoc false

  alias Assistant.HexPm.Package

  @behaviour Assistant.HexPm.Client

  @endpoint "https://hex.pm/api"

  @impl true
  def packages(params) do
    case call("/packages", params) do
      {:ok, list} ->
        packages = Enum.map(list, &Package.from/1)

        {:ok, packages}

      e ->
        e
    end
  end

  @spec call(String.t(), keyword) :: {:ok, map | list | integer} | {:error, any}
  def call(path, params \\ []) do
    query_string = URI.encode_query(Enum.into(params, %{}))

    url =
      if query_string != "" do
        "#{@endpoint}#{path}?#{query_string}"
      else
        "#{@endpoint}#{path}"
      end

    url |> get() |> handle_response()
  end

  defp get(url) do
    :get |> Finch.build(url) |> Finch.request(MyFinch)
  end

  defp handle_response({:ok, resp}) do
    {:ok, Jason.decode!(resp.body)}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
