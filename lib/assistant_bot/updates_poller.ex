defmodule AssistantBot.UpdatesPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias AssistantBot.Consumer

  require Logger

  typedstruct module: State do
    field :offset, integer, default: 0
  end

  @allowed_updates [
    "message",
    "callback_query"
  ]

  def start_link(_) do
    # 初始化 bot 信息
    AssistantBot.init()
    # 删除可能存在的 webhook 模式
    Telegex.delete_webhook()

    Logger.info("Bot (@#{AssistantBot.username()}) is working")

    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("Updates poller has started")

    schedule_pull_updates()

    {:ok, state}
  end

  @doc """
  处理消息。

  每收到一次 `:pull` 消息，就获取下一次更新，并修改状态中的 `offset` 值。
  """
  @impl true
  def handle_info(:pull, %{offset: offset} = state) do
    offset =
      case Telegex.get_updates(offset: offset, allowed_updates: @allowed_updates) do
        {:ok, updates} ->
          # 消费消息
          Enum.each(updates, &Consumer.receive/1)

          if Enum.empty?(updates) do
            offset
          else
            # 计算新的 offset
            List.last(updates).update_id + 1
          end

        {:error, %Telegex.Error{description: "Bad Gateway"}} ->
          # TG 服务器故障，大幅度降低请求频率
          :timer.sleep(500)

          offset

        {:error, reason} ->
          Logger.warning("Pull updates failed: #{inspect(reason: reason)}")

          # 发生错误，降低请求频率
          :timer.sleep(200)

          offset
      end

    # 每 35ms 一个拉取请求，避免 429 错误
    :timer.sleep(35)

    schedule_pull_updates()

    {:noreply, %{state | offset: offset}}
  end

  @impl true
  def handle_info({:ssl_closed, _} = msg, state) do
    Logger.warning("Known network failure: #{inspect(msg: msg)}")

    {:noreply, state}
  end

  defp schedule_pull_updates do
    send(self(), :pull)
  end
end
