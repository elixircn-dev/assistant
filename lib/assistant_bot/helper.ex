defmodule AssistantBot.Helper do
  @moduledoc false

  def action(%{action: nil} = context, action)
      when is_struct(context, AssistantBot.ChainContext) do
    %{context | action: action}
  end

  def action(context, action) do
    raise "Duplicated action setting: #{inspect(action: action, context: context)}"
  end
end
