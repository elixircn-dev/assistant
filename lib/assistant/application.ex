defmodule Assistant.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    config = Application.get_env(:assistant, __MODULE__)

    tg_serve? = config[:tg_serve] || false

    children =
      [
        # Starts a worker by calling: Assistant.Worker.start_link(arg)
        # {Assistant.Worker, arg}

        # 发布/订阅服务。
        {Phoenix.PubSub, name: Assistant.PubSub},
        # 基于 :dets 的简单存储。
        Assistant.EasyStore,
        # Hex.pm 包发布的消费者。
        Assistant.HexPm.Consumer,
        # Hex.pm 最近包的轮询器。
        Assistant.HexPm.RecentlyPoller,
        # 轮询读取 GitHub 通知。
        Assistant.GitHub.NotificationsPoller,
        # 定时任务调度器。
        Assistant.Scheduler
      ]
      # Start the Telegram bot
      |> serve_children(AssistantBot.Supervisor, tg_serve?)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Assistant.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp serve_children(children, child, server?) do
    children ++
      if server? do
        [child]
      else
        []
      end
  end
end
