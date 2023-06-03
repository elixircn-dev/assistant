defmodule Assistant.HexPm.ClientImpl do
  @moduledoc false

  alias Assistant.HexPm.Package

  @behaviour Assistant.HexPm.Client

  @endpoint "https://hex.pm"

  @impl true
  def packages(params) do
    case request("/packages", params) do
      {:ok, document} ->
        packages =
          document
          |> Floki.find(".package-list > ul > li")
          |> Enum.map(&Package.from/1)

        {:ok, packages}

      e ->
        e
    end
  end

  @spec request(String.t(), keyword) :: {:ok, map | list | integer} | {:error, any}
  def request(path, params \\ []) do
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
    HTTPoison.get(url)
  end

  defp handle_response({:ok, resp}) do
    Floki.parse_document(resp.body)
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
