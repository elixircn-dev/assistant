defmodule AssistantBot.InitFromSelfChain do
  @moduledoc false

  use AssistantBot.Chain

  @impl true
  def handle(_update, %{user_id: user_id} = context) do
    context = %{context | from_self: user_id == Telegex.Instance.me().id}

    {:ok, context}
  end

  @impl true
  def handle(_update, context), do: {:ok, context}
end
