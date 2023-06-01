defmodule AssistantBot.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    install_plugs([
      # 初始化发送来源，必须位于第一个
      AssistantBot.InitSendSourcePlug,
      # 初始化 `from_owner` 字段
      AssistantBot.InitFromOwnerPlug,
      # 初始化 `from_self` 字段
      AssistantBot.InitFromSelfPlug,
      # 响应 `/start` 命令
      AssistantBot.RespStartCmdPlug,
      # 响应 `/run` 命令
      AssistantBot.RespRunCmdPlug,
      # 响应 `/clear` 命令
      AssistantBot.RespClearCmdPlug
    ])

    children = [
      # 消费更新的动态主管。
      AssistantBot.Consumer,
      # 更新的拉取器。
      AssistantBot.UpdatesPoller
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end

  defp install_plugs(plugs) do
    Telegex.Plug.Pipeline.install_all(plugs)
  end
end
