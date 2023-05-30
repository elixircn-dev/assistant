defmodule AssistantBot.InitSendSourcePlug do
  @moduledoc false

  use AssistantBot, plug: :preheater

  import AssistantBot.Helper.FromParser

  @impl true
  def call(update, state) do
    case parse(update) do
      {chat_id, user_id} ->
        state = %{state | chat_id: chat_id, user_id: user_id}

        {:ok, state}

      nil ->
        {:ignored, state}
    end
  end
end
