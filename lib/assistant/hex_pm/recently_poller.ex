defmodule Assistant.HexPm.RecentlyPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias Assistant.HexPm.{Consumer, Package}

  import Assistant.HexPm.Client

  @type skus_type :: [String.t()]

  # 每 61 秒读取一次通知
  @interval 61 * 1000

  require Logger

  typedstruct module: State do
    field :boot_skus, String.t()
    field :last_skus, String.t()
  end

  def start_link(_) do
    {:ok, packages} = packages(page: 1, sort: :updated_at)

    skus = gen_skus(packages)

    GenServer.start_link(__MODULE__, %State{boot_skus: skus}, name: __MODULE__)
  end

  @impl true
  def init(%{boot_skus: [sku1, sku2]} = state) do
    Logger.info("Hex.pm recently poller is working #{inspect(boot_skus: sku1 <> "+" <> sku2)}")

    delay_schedule_pull_packages()

    {:ok, state}
  end

  @doc """
  读取通知。

  每收到一次 `:pull` 消息，就读取一次包列表，并缓存最新的 skus。
  """
  @impl true
  def handle_info(:pull, state) do
    skus = state.last_skus || state.boot_skus

    skus =
      case new_packages(skus) do
        {:ok, packages, skus} ->
          # 消费新的包版本
          Enum.each(packages, &Consumer.receive/1)

          skus

        {:error, reason} ->
          # 发生错误，返回当前 `skus`
          Logger.warning("[hex_pm] Pull packages failed: #{inspect(reason: reason)}")

          skus
      end

    :timer.sleep(@interval)

    schedule_pull_packages()

    {:noreply, %{state | last_skus: skus}}
  end

  defp schedule_pull_packages do
    send(self(), :pull)
  end

  # 延迟调度通知包列表，避免后续消费进程未启动。通常此函数在 `init/1` 中用作初次调用。 
  defp delay_schedule_pull_packages do
    Process.send_after(self(), :pull, @interval)
  end

  def set_last_skus(p1, p2) when is_struct(p1, Package) and is_struct(p2, Package) do
    GenServer.cast(__MODULE__, {:set_last_skus, [Package.sku(p1), Package.sku(p2)]})
  end

  @impl true
  def handle_cast({:set_last_skus, skus}, state) do
    {:noreply, %{state | last_skus: skus}}
  end
end
