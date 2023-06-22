defmodule AssistantBot.ChainHandler do
  @moduledoc false

  use Telegex.Chain.Handler

  pipeline([
    # 初始化发送来源，必须位于第一个
    AssistantBot.InitSendSourceChain,
    # 初始化 `from_owner` 字段
    AssistantBot.InitFromOwnerChain,
    # 初始化 `from_self` 字段
    AssistantBot.InitFromSelfChain,
    # 响应 `/start` 命令
    AssistantBot.RespStartChain,
    # 响应 `/run` 命令
    AssistantBot.RespRunChain,
    # 响应 `/clear` 命令
    AssistantBot.RespClearChain,
    # 响应 `/subscribed` 命令
    AssistantBot.RespSubscribedChain,
    # 响应 `/subscribe` 命令
    AssistantBot.RespSubscribeChain,
    # 响应 `/unsubscribe` 命令
    AssistantBot.RespUnSubscribeChain
  ])
end
