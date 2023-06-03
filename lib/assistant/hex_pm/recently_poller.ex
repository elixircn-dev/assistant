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
    {:ok, [p1_sku, p2_sku]} = last_updated_packages(2)

    GenServer.start_link(__MODULE__, %State{boot_skus: [p1_sku, p2_sku]}, name: __MODULE__)
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

  @spec new_packages([String.t()], integer, list, list) ::
          {:ok, [Package.t()], skus_type} | {:error, any}
  def new_packages(skus, page \\ 1, all \\ [], new \\ []) do
    append_fun = fn p, new ->
      psku = Package.sku(p)

      cond do
        match?([^psku, _], skus) ->
          # 与最新的 sku 匹配，停止迭代
          {:halt, new}

        match?([_, ^psku], skus) ->
          # 与第二个 sku 匹配，停止迭代
          # 达到此处是因为最新的 sku 关联包升级了，达到第二个匹配的 sku，相当于第二重保证
          # 假设在一个周期内，两个 sku 相关的包都升级了，就会出现无限递扫描包的情况，但发生机率非常小。如果发生，可以用更多数量的 sku 来保证
          {:halt, new}

        true ->
          {:cont, new ++ [p]}
      end
    end

    case packages(page: page, sort: :updated_at) do
      {:ok, packages} ->
        all = all ++ packages

        new = Enum.reduce_while(packages, new, append_fun)

        cond do
          Enum.empty?(packages) ->
            {:ok, Enum.reverse(new), gen_last_skus(all)}

          length(new) < length(all) ->
            {:ok, Enum.reverse(new), gen_last_skus(all)}

          true ->
            new_packages(skus, page + 1, all, new)
        end

      e ->
        e
    end
  end

  @spec gen_last_skus([Package.t()]) :: skus_type
  defp gen_last_skus(packages) do
    [p1, p2 | _] = packages

    [Package.sku(p1), Package.sku(p2)]
  end

  def set_last_skus(p1, p2) when is_struct(p1, Package) and is_struct(p2, Package) do
    GenServer.cast(__MODULE__, {:set_last_skus, [Package.sku(p1), Package.sku(p2)]})
  end

  @impl true
  def handle_cast({:set_last_skus, skus}, state) do
    {:noreply, %{state | last_skus: skus}}
  end
end
