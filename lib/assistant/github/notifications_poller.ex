defmodule Assistant.GitHub.NotificationsPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias Assistant.Subscriptions
  alias Assistant.GitHub.Consumer

  import Assistant.GitHub.Client

  # 每 61 秒读取一次通知
  @interval 61 * 1000

  require Logger

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
    offset = Subscriptions.get_github_notifications_offset()

    offset =
      case new_notifications(offset) do
        {:ok, []} ->
          offset

        {:ok, notifications} ->
          # 消费通知
          Enum.each(notifications, &Consumer.receive/1)

          # 返回最新的 `offset`
          notifications |> List.last() |> Map.get("id") |> String.to_integer()

        {:error, reason} ->
          Logger.warning("[github] Pull notifications failed: #{inspect(reason: reason)}")

          offset
      end

    :ok = Subscriptions.put_github_notifications_offset(offset)

    :timer.sleep(@interval)

    schedule_pull_notifications()

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
end
