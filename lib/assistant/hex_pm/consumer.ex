defmodule Assistant.HexPm.Consumer do
  @moduledoc false

  use DynamicSupervisor
  use Assistant.PubSub

  alias Assistant.Subscriptions
  alias Assistant.HexPm.Package

  require Logger

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def receive(%Package{} = package) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Task, fn -> dispatch(package) end}
    )
  end

  def dispatch(%{name: name, version: version} = package) do
    subscribed? = Enum.member?(Subscriptions.hex_pm_subscribed_pkgs(), name)

    if subscribed? do
      Logger.debug(
        "[hex_pm] Dispatch version for subscribed package: #{inspect(name: name, version: version)}"
      )

      # 派发已订阅包的新版本
      _dispatch(package)

      :ok
    else
      Logger.debug(
        "[hex_pm] Ignore version for unsubscribed package: #{inspect(name: name, version: version)}"
      )

      :ignored
    end
  end

  def dispatch(_), do: :unkown_package

  def _dispatch(package) do
    :ok = broadcast("hex_pm", {:pkg_publish, package})
  end
end
