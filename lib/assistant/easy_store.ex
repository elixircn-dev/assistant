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

  @spec get(atom, any) :: any
  def get(key, default \\ nil) do
    GenServer.call(__MODULE__, {:get, key, default})
  end

  @spec put(atom, any) :: :ok
  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  @spec delete(atom) :: :ok
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def list_append(key, value, opts \\ []) do
    GenServer.call(__MODULE__, {:list_append, key, value, opts})
  end

  # TODO: 将此函数改为并发安全型
  def list_remove(key, value) do
    case get(key) do
      nil -> :ok
      list when is_list(list) -> put(key, List.delete(list, value))
      _ -> :non_list
    end
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    :ok = backend_put(state.table, key, value)

    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    :dets.delete(state.table, key)

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key, default}, _from, state) do
    {:reply, backend_lookup(state.table, key, default), state}
  end

  def handle_call({:list_append, key, value, opts}, _from, state) do
    unique? = Enum.member?(opts, :unique) || Keyword.get(opts, :unique, false)

    filter_list = fn list, value ->
      if unique? && Enum.member?(list, value) do
        list
      else
        list ++ [value]
      end
    end

    case backend_lookup(state.table, key, []) do
      list when is_list(list) ->
        updated_value = filter_list.(list, value)
        :ok = backend_put(state.table, key, updated_value)

        {:reply, updated_value, state}

      _ ->
        {:reply, :bad_type, state}
    end
  end

  @impl true
  def terminate(_reason, state) do
    :dets.close(state.table)
  end

  defp backend_lookup(table, key, default) do
    case :dets.lookup(table, key) do
      [] -> default
      [{_, value}] -> value
    end
  end

  defp backend_put(table, key, value) do
    :dets.insert(table, {key, value})
  end
end
