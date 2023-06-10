defmodule AssistantBot do
  @moduledoc false

  alias Telegex.Type.User, as: TgUser
  alias Telegex.Type.BotCommand

  require Logger

  @type config_key :: :owner_id | :group_id | :work_mode

  defmacro __using__(plug: opts) do
    quote do
      use Telegex.Plug.Presets, unquote(opts)
      use Assistant.I18n

      import Assistant.Gettext
      import AssistantBot.{Helper, State, MessageCaller}
    end
  end

  defmodule Info do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :id, integer
      field :username, String.t()
      field :name, String.t()
    end
  end

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

  # 初始化机器人信息
  def init do
    if :ets.whereis(Info) == :undefined do
      Logger.info("Checking bot information...")

      %{username: username} = info = fetch_info()

      # 更新 `Telegex.Plug` 中缓存的用户名
      Telegex.Plug.update_username(username)
      # 缓存机器人数据
      :ets.new(Info, [:set, :named_table])
      :ets.insert(Info, {:bot_info, info})

      # 设置命令列表
      Telegex.set_my_commands(@commands)

      info
    else
      :ets.lookup(Info, :bot_info)
    end
  end

  @spec username :: String.t() | nil
  def username, do: info_attr(:username)

  @spec id :: integer | nil
  def id, do: info_attr(:id)

  def info_attr(field, default \\ nil) do
    if info = info() do
      Map.get(info, field, default)
    else
      default
    end
  end

  @spec info :: Info.t() | nil
  def info() do
    case :ets.lookup(Info, :bot_info) do
      [{:bot_info, value}] ->
        value

      _ ->
        nil
    end
  end

  @spec fetch_info :: Info.t()
  defp fetch_info do
    case Telegex.get_me() do
      {:ok, %TgUser{id: id, username: username, first_name: first_name}} ->
        %Info{
          id: id,
          username: username,
          name: first_name
        }

      {:error, %{reason: reason}} when reason in [:timeout, :closed] ->
        Logger.warning("Retrying bot info check due to network issue...")

        fetch_info()

      {:error, e} ->
        raise e
    end
  end

  @spec config(config_key, any) :: any
  def config(key, default \\ nil) do
    Application.get_env(:assistant, __MODULE__)[key] || default
  end

  def work_mode, do: config(:work_mode)
end
