defmodule AssistantBot.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    updates_handler =
      if AssistantBot.work_mode() == :webhook do
        # webhook
        AssistantBot.HookHandler
      else
        # polling
        AssistantBot.PollingHandler
      end

    children = [
      # 更新处理器（兼容两种模式）
      updates_handler,
      # 广播中心
      AssistantBot.BroadcastCenter
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)
  end
end
