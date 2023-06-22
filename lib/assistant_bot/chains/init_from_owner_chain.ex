defmodule AssistantBot.InitFromOwnerChain do
  @moduledoc false

  use AssistantBot.Chain

  @impl true
  def handle(_update, %{user_id: user_id} = context) do
    context = %{context | from_owner: user_id == AssistantBot.config(:owner_id)}

    {:ok, context}
  end
end
