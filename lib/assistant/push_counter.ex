defmodule Assistant.PushCounter do
  @moduledoc false

  use GenServer
  use TypedStruct

  alias :dets, as: Dets

  require Logger

  typedstruct module: State do
    field :table, atom, enforce: true
  end

  defp file_path do
    data_dir = Assistant.data_dir()

    data_dir |> Path.join("push_counter") |> String.to_charlist()
  end

  def start_link(_) do
    {:ok, table} = Dets.open_file(:push_counter, type: :set, auto_save: 5, file: file_path())

    GenServer.start_link(__MODULE__, %State{table: table}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @doc """
  自增指定 `key` 的计数。
  """
  def increase(key) do
    GenServer.cast(__MODULE__, {:increase, key})
  end

  @doc """
  获取指定 `key` 的计数。
  """
  def get_count(key) do
    GenServer.call(__MODULE__, {:get_count, key})
  end

  @impl true
  def handle_cast({:increase, key}, state) do
    current = backend_lookup(state.table, key, 0)

    case backend_put(state.table, key, current + 1) do
      :ok ->
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Increment push counts failed: #{inspect(key: key, reason: reason)}")

        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:get_count, key}, _from, state) do
    {:reply, backend_lookup(state.table, key, 0), state}
  end

  defp backend_lookup(table, key, default) do
    case Dets.lookup(table, key) do
      [] -> default
      [{_, value}] -> value
    end
  end

  defp backend_put(table, key, value) do
    Dets.insert(table, {key, value})
  end
end
