defmodule AssistantBot.State do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :action, atom
    field :from_self, boolean, default: false
    field :from_owner, boolean, default: false
    field :chat_id, integer
    field :user_id, integer
    field :done, boolean, default: false
  end

  def action(%{action: nil} = state, action) do
    %{state | action: action}
  end

  def action(state, action) do
    raise "Duplicated action setting: #{inspect(action: action, state: state)}"
  end

  def done(state) do
    %{state | done: true}
  end
end
