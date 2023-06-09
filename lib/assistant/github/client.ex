defmodule Assistant.GitHub.Client do
  @moduledoc false

  @endpoint "https://api.github.com"

  def me, do: call(:get, "/user")

  def new_notifications(offset, page \\ 1, all \\ [], new \\ []) do
    append_fun = fn n, new ->
      if String.to_integer(n["id"]) > offset do
        {:cont, new ++ [n]}
      else
        {:halt, new}
      end
    end

    case notifications(page: page, per_page: 50) do
      {:ok, notifications} ->
        all = all ++ notifications

        new = Enum.reduce_while(notifications, new, append_fun)

        cond do
          Enum.empty?(notifications) ->
            {:ok, Enum.reverse(new)}

          length(new) < length(all) ->
            {:ok, Enum.reverse(new)}

          true ->
            new_notifications(offset, page + 1, all, new)
        end

      e ->
        e
    end
  end

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

          request(method, url, json_body)

        method when method in [:get, :delete] ->
          query_string = URI.encode_query(Enum.into(params, %{}))

          url =
            if query_string != "" do
              "#{url}?#{query_string}"
            else
              url
            end

          request(method, url)
      end

    handle_response(r)
  end

  defp full_url(<<@endpoint <> _path::binary>> = url) do
    url
  end

  defp full_url(<<"/" <> _rest::binary>> = url) do
    "#{@endpoint}#{url}"
  end

  @accept_header {"accept", "application/vnd.github+json"}

  def request(method, url) do
    method |> Finch.build(url, [@accept_header, authorization_header()]) |> Finch.request(MyFinch)
  end

  def request(method, url, body) do
    method
    |> Finch.build(url, [@accept_header, authorization_header()], body)
    |> Finch.request(MyFinch)
  end

  defp handle_response({:ok, %{status: 204} = _resp}) do
    {:ok, 204}
  end

  defp handle_response({:ok, %{status: 404} = _resp}) do
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

    {"authorization", "Bearer #{token}"}
  end
end
