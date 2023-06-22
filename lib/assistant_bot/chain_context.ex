defmodule AssistantBot.ChainContext do
  @moduledoc false

  use Telegex.Chain.Context

  defcontext([
    {:action, atom},
    {:from_self, boolean, default: false},
    {:from_owner, boolean, default: false},
    {:chat_id, integer},
    {:user_id, integer}
  ])
end
