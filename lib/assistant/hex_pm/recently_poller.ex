defmodule Assistant.HexPm.RecentlyPoller do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias Assistant.HexPm.{Consumer, Package}

  import Assistant.HexPm.Client

  # 每 61 秒读取一次通知
  @interval 61 * 1000

  require Logger

  typedstruct module: State do
    field :boot_sku, String.t()
    field :last_sku, String.t()
  end

  def start_link(_) do
    {:ok, p} = last_updated_package()

    GenServer.start_link(__MODULE__, %State{boot_sku: Package.sku(p)}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("Hex.pm recently poller is working #{inspect(boot_sku: state.boot_sku)}")

    delay_schedule_pull_packages()

    {:ok, state}
  end

  @doc """
  读取通知。

  每收到一次 `:pull` 消息，就读取一次包列表，并写入最新的 sku。
  """
  @impl true
  def handle_info(:pull, state) do
    sku = state.last_sku || state.boot_sku

    sku =
      case get_packages(sku) do
        {:ok, packages} ->
          # 消费新的包版本
          Enum.each(packages, &Consumer.receive/1)

          if Enum.empty?(packages) do
            sku
          else
            # 返回最新的 `sku`
            packages |> List.last() |> Package.sku()
          end

        {:error, reason} ->
          Logger.warning("[hex_pm] Pull packages failed: #{inspect(reason: reason)}")

          sku
      end

    :timer.sleep(@interval)

    schedule_pull_packages()

    {:noreply, %{state | last_sku: sku}}
  end

  defp schedule_pull_packages do
    send(self(), :pull)
  end

  # 延迟调度通知包列表，避免后续消费进程未启动。通常此函数在 `init/1` 中用作初次调用。 
  defp delay_schedule_pull_packages do
    Process.send_after(self(), :pull, @interval)
  end

  def get_packages(sku, page \\ 1, all \\ [], new \\ []) do
    append_fun = fn p, new ->
      if Package.sku(p) != sku do
        {:cont, new ++ [p]}
      else
        {:halt, new}
      end
    end

    case packages(page: page, sort: :updated_at) do
      {:ok, packages} ->
        all = all ++ packages

        new = Enum.reduce_while(packages, new, append_fun)

        cond do
          Enum.empty?(packages) ->
            {:ok, Enum.reverse(new)}

          length(new) < length(all) ->
            {:ok, Enum.reverse(new)}

          true ->
            get_packages(sku, page + 1, all, new)
        end

      e ->
        e
    end
  end

  def set_last_sku(package) when is_struct(package, Package) do
    GenServer.cast(__MODULE__, {:set_last_sku, Package.sku(package)})
  end

  @impl true
  def handle_cast({:set_last_sku, sku}, state) do
    {:noreply, %{state | last_sku: sku}}
  end
end
