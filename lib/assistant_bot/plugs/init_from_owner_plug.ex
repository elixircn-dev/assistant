defmodule AssistantBot.InitFromOwnerPlug do
  @moduledoc false

  use AssistantBot, plug: :preheater

  @impl true
  def call(_update, %{user_id: user_id} = state) do
    state = %{state | from_owner: user_id == AssistantBot.config(:owner_id)}

    {:ok, state}
  end
end
