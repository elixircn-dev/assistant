defmodule Assistant.HexPm.Client do
  @moduledoc false

  alias Assistant.HexPm.Package

  @endpoint "https://hex.pm"

  @spec last_updated_package :: {:ok, Package.t()} | {:error, any}
  def last_updated_package do
    case packages(page: 1, sort: :updated_at) do
      {:ok, packages} -> {:ok, hd(packages)}
      e -> e
    end
  end

  @type packages_opts :: [page: integer, sort: :updated_at]

  @spec packages(packages_opts) :: {:ok, [Package.t()]} | {:error, any}
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
