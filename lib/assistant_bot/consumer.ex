defmodule AssistantBot.Consumer do
  @moduledoc false

  use DynamicSupervisor

  alias AssistantBot.State

  require Logger

  def start_link(default \\ []) when is_list(default) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def receive(%Telegex.Model.Update{} = update) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Task, fn -> task(update) end}
    )
  end

  defp task(update) do
    Telegex.Plug.Pipeline.call(update, %State{})
  rescue
    e ->
      import AssistantBot.Helper.FromParser

      chat_id = parse_chat_id(update)

      Logger.error(
        "Uncaught Error: #{inspect(exception: e)}\n#{Exception.format(:error, e, __STACKTRACE__)}",
        chat_id: chat_id
      )
  end
end