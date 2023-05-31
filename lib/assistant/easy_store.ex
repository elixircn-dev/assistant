defmodule Assistant.EasyStore do
  @moduledoc false

  use GenServer
  use TypedStruct

  typedstruct module: State do
    field :table, atom, enforce: true
  end

  defp file_path do
    data_dir = Assistant.data_dir()

    data_dir |> Path.join("easy_store") |> String.to_charlist()
  end

  def start_link(_) do
    {:ok, table} = :dets.open_file(:easy_store, type: :set, auto_save: 5, file: file_path())

    GenServer.start_link(__MODULE__, %State{table: table}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @spec put(atom, any) :: :ok
  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  @spec delete(atom) :: :ok
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @spec get(atom, any) :: any
  def get(key, default \\ nil) do
    GenServer.call(__MODULE__, {:get, key}) || default
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    :dets.insert(state.table, {key, value})

    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    :dets.delete(state.table, key)

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case :dets.lookup(state.table, key) do
      [] -> {:reply, nil, state}
      [{_, value}] -> {:reply, value, state}
    end
  end

  @impl true
  def terminate(_reason, state) do
    :dets.close(state.table)
  end
end
