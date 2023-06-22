defmodule AssistantBot.InitSendSourceChain do
  @moduledoc false

  use AssistantBot.Chain

  import AssistantBot.Helper.FromParser

  @impl true
  def handle(update, context) do
    case parse(update) do
      {chat_id, user_id} ->
        context = %{context | chat_id: chat_id, user_id: user_id}

        {:ok, context}

      nil ->
        {:ok, context}
    end
  end
end
