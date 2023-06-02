defmodule AssistantBot.UpdatesPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias AssistantBot.{Info, Consumer}
  alias Telegex.Model.User, as: TgUser
  alias Telegex.Model.BotCommand

  require Logger

  typedstruct module: State do
    field :offset, integer, default: 0
  end

  @allowed_updates [
    "message",
    "callback_query"
  ]

  @commands [
    %BotCommand{
      command: "subscribe_repo",
      description: "订阅 GitHub 仓库"
    },
    %BotCommand{
      command: "unsubscribe_repo",
      description: "取消订阅 GitHub 仓库"
    },
    %BotCommand{
      command: "subscribed_repos",
      description: "已订阅的仓库列表"
    },
    %BotCommand{
      command: "clear",
      description: "清理某些缓存"
    },
    %BotCommand{
      command: "run",
      description: "运行某些任务"
    }
  ]

  def start_link(default \\ []) when is_list(default) do
    # 初始化 bot 信息
    if :ets.whereis(Info) == :undefined do
      init_bot_info()
    else
      :ets.lookup(Info, :bot_info)
    end

    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  defp init_bot_info do
    # 获取机器人必要信息
    Logger.info("Checking bot information...")

    %{username: username} = bot_info = get_bot_info()

    Logger.info("Bot (@#{username}) is working")

    # 更新 `Telegex.Plug` 中缓存的用户名
    Telegex.Plug.update_username(username)
    # 缓存机器人数据
    :ets.new(Info, [:set, :named_table])
    :ets.insert(Info, {:bot_info, bot_info})

    # 设置命令列表
    Telegex.set_my_commands(@commands)

    bot_info
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

        {:error, %Telegex.Model.Error{description: "Bad Gateway"}} ->
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

  @doc """
  获取机器人信息。

  此函数在遇到部分网络故障后会自动重试，且没有次数上限。
  """
  @spec get_bot_info() :: Info.t()
  def get_bot_info do
    case Telegex.get_me() do
      {:ok, %TgUser{id: id, username: username, first_name: first_name}} ->
        %Info{
          id: id,
          username: username,
          name: first_name
        }

      {:error, %{reason: reason}} when reason in [:timeout, :closed] ->
        Logger.warning("Retrying bot info check due to network issue...")

        get_bot_info()

      {:error, e} ->
        raise e
    end
  end
end
