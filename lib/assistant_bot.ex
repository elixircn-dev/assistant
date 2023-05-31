defmodule AssistantBot do
  @moduledoc false

  @type config_key :: :owner_id | :group_id

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

  @spec config(config_key, any) :: any
  def config(key, default \\ nil) do
    Application.get_env(:assistant, __MODULE__)[key] || default
  end
end
