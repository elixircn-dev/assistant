defmodule AssistantBot.InitFromSelfPlug do
  @moduledoc false

  use AssistantBot, plug: :preheater

  @impl true
  def call(_update, %{user_id: user_id} = state) do
    state = %{state | from_self: user_id == AssistantBot.id()}

    {:ok, state}
  end

  def call(_update, state), do: {:ignored, state}
end
