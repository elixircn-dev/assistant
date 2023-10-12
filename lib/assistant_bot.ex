defmodule AssistantBot do
  @moduledoc false

  alias Telegex.Type.BotCommand

  require Logger

  @type config_key :: :owner_id | :group_id | :work_mode

  @commands [
    %BotCommand{
      command: "subscribe",
      description: "订阅新内容"
    },
    %BotCommand{
      command: "unsubscribe",
      description: "取消已订阅的内容"
    },
    %BotCommand{
      command: "subscribed",
      description: "已订阅的内容列表"
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

  defmodule Chain do
    @moduledoc false

    defmacro __using__(opts) do
      quote do
        use Telegex.Chain, unquote(opts)
        use Assistant.I18n

        import Assistant.Gettext
        import AssistantBot.{Helper, MessageCaller}
      end
    end
  end

  @doc """
  初始化配置机器人。
  """
  @spec init :: {:ok, Telegex.Type.User.t()} | {:error, Telegex.Type.error()}
  def init do
    # 设置命令列表
    {:ok, true} = Telegex.set_my_commands(@commands)

    Telegex.Instance.fetch_me()
  end

  def work_mode, do: config(:work_mode)

  @spec config(config_key, any) :: any
  def config(key, default \\ nil) do
    Application.get_env(:assistant, __MODULE__)[key] || default
  end
end
