defmodule Assistant.GitHub.Client do
  @moduledoc false

  @endpoint "https://api.github.com"

  def me, do: call(:get, "/user")

  @spec notifications(keyword) :: {:ok, list} | {:error, any}
  def notifications(params \\ []), do: call(:get, "/notifications", params)

  def subscribe(owner, repo) do
    call(:put, "/repos/#{owner}/#{repo}/subscription", %{subscribed: true, ignored: false})
  end

  @spec unsubscribe(String.t(), String.t()) :: {:ok, integer} | {:error, any}
  def unsubscribe(owner, repo) do
    call(:delete, "/repos/#{owner}/#{repo}/subscription")
  end

  @spec call(atom, String.t(), map | keyword) :: {:ok, map | list | integer} | {:error, any}
  def call(method, path_or_url, params \\ []) do
    url = full_url(path_or_url)

    r =
      case method do
        method when method in [:put, :post] ->
          json_body = Jason.encode!(params)

          apply(__MODULE__, method, [url, json_body])

        method when method in [:get, :delete] ->
          query_string = URI.encode_query(Enum.into(params, %{}))

          url =
            if query_string != "" do
              "#{url}?#{query_string}"
            else
              url
            end

          apply(__MODULE__, method, [url])
      end

    handle_response(r)
  end

  defp full_url(<<@endpoint <> _path::binary>> = url) do
    url
  end

  defp full_url(<<"/" <> _rest::binary>> = url) do
    "#{@endpoint}#{url}"
  end

  @accept_header {"Accept", "application/vnd.github+json"}

  def post(url, body) do
    HTTPoison.post(url, body, [@accept_header, authorization_header()])
  end

  def put(url, body) do
    HTTPoison.put(url, body, [@accept_header, authorization_header()])
  end

  def get(url) do
    HTTPoison.get(url, [@accept_header, authorization_header()])
  end

  def delete(url) do
    HTTPoison.delete(url, [@accept_header, authorization_header()])
  end

  defp handle_response({:ok, %{status_code: 204} = _resp}) do
    {:ok, 204}
  end

  defp handle_response({:ok, %{status_code: 404} = _resp}) do
    {:error, 404}
  end

  defp handle_response({:ok, resp}) do
    json = Jason.decode!(resp.body)

    {:ok, json}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end

  defp authorization_header do
    token = Application.get_env(:assistant, :github_token)

    {"Authorization", "Bearer #{token}"}
  end
end
