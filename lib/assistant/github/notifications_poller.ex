defmodule Assistant.GitHub.NotificationsPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias Assistant.EasyStore
  alias Assistant.GitHub.Consumer

  import Assistant.GitHub.Client

  # 每 61 秒读取一次通知
  @interval 61 * 1000

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
      case get_notifications(offset) do
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

    :timer.sleep(@interval)

    schedule_pull_notifications()

    :ok = EasyStore.put(@store_key, offset)

    {:noreply, state}
  end

  @impl true
  def init(state) do
    Logger.info("GitHub account (@#{state.username}) is working")

    delay_schedule_pull_notifications()

    {:ok, state}
  end

  defp schedule_pull_notifications do
    send(self(), :pull)
  end

  # 延迟调度通知读取，避免后续消费进程未启动。通常此函数在 `init/1` 中用作初次调用。 
  defp delay_schedule_pull_notifications do
    Process.send_after(self(), :pull, @interval)
  end

  def get_notifications(offset, page \\ 1, all \\ [], new \\ []) do
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
            get_notifications(offset, page + 1, all, new)
        end

      e ->
        e
    end
  end
end
