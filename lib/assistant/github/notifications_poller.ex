defmodule Assistant.GitHub.NotificationsPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias Assistant.EasyStore
  alias Assistant.GitHub.Consumer

  require Logger

  @store_key :github_notifications_offset

  typedstruct module: State do
    field :user_id, integer
    field :username, String.t()
    field :name, String.t()
  end

  def start_link(_) do
    {:ok, user} = me()

    state = %State{
      user_id: user["id"],
      username: user["login"],
      name: user["name"]
    }

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  读取通知。

  每收到一次 `:pull` 消息，就读取一次通知，并将最新的通知 ID 写入通知偏移量。
  """
  @impl true
  def handle_info(:pull, state) do
    offset = EasyStore.get(@store_key, 0)

    offset =
      case new_notifications(offset) do
        {:ok, notifications} ->
          # 消费通知
          Enum.each(notifications, &Consumer.dispatch/1)

          if Enum.empty?(notifications) do
            offset
          else
            # 返回最新的 `offset`
            notifications |> List.last() |> Map.get("id") |> String.to_integer()
          end

        {:error, reason} ->
          Logger.warning("[github] Pull notifications failed: #{inspect(reason: reason)}")

          offset
      end

    # 每 61 秒一个请求
    :timer.sleep(61 * 1000)

    schedule_pull_notifications()

    :ok = EasyStore.put(@store_key, offset)

    {:noreply, state}
  end

  @impl true
  def init(state) do
    Logger.info("GitHub account (@#{state.username}) is working")

    schedule_pull_notifications()

    {:ok, state}
  end

  defp schedule_pull_notifications do
    send(self(), :pull)
  end

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
            {:ok, new}

          length(new) < length(all) ->
            {:ok, new}

          true ->
            new_notifications(offset, page + 1, all, new)
        end

      e ->
        e
    end
  end

  def me, do: call(:get, "/user")

  def notifications(params), do: call(:get, "/notifications", params)

  def subscription(owner, repo) do
    call(:put, "/repos/#{owner}/#{repo}/subscription", %{subscribed: true, ignored: false})
  end

  @accept_header {"Accept", "application/vnd.github+json"}

  @spec call(atom, String.t(), map | keyword) :: {:ok, map | list} | {:error, any}
  def call(method, path, params \\ []) do
    url = "https://api.github.com#{path}"

    r =
      case method do
        :put ->
          json_body = Jason.encode!(params)

          put(url, json_body)

        :get ->
          query_string = URI.encode_query(Enum.into(params, %{}))

          url =
            if query_string != "" do
              "#{url}?#{query_string}"
            else
              url
            end

          get(url)
      end

    handle_response(r)
  end

  def put(url, body) do
    HTTPoison.put(url, body, [@accept_header, authorization_header()])
  end

  def get(url) do
    HTTPoison.get(url, [@accept_header, authorization_header()])
  end

  def handle_response({:ok, resp}) do
    json = Jason.decode!(resp.body)

    {:ok, json}
  end

  def handle_response({:error, reason}) do
    {:error, reason}
  end

  defp authorization_header do
    token = Application.get_env(:assistant, :github_token)

    {"Authorization", "Bearer #{token}"}
  end
end
