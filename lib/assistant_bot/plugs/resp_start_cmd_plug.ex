defmodule AssistantBot.RespStartCmdPlug do
  @moduledoc false

  use AssistantBot, plug: [commander: :start]

  # 重写匹配规则，以 `/start` 开始即匹配。
  @impl true
  def match(text, state) do
    if String.starts_with?(text, @command) do
      {:match, state}
    else
      {:nomatch, state}
    end
  end

  # 忽略非私聊消息。
  @impl true
  def handle(%{chat: %{type: chat_type}}, state) when chat_type != "private" do
    {:ignored, state}
  end

  @impl true
  def handle(_message, state) do
    thello = commands_text("你好，我是来自 %{chat_link} 的开源机器人助理", chat_link: "@elixircn_dev")

    tdetais =
      commands_text("访问 %{link} 了解我的更多细节～",
        link: ~s|<a href="https://github.com/elixircn-dev/assistant">elixircn-dev/assistant</a>|
      )

    text = """
    #{thello} 😀

    #{tdetais}
    """

    send_text(state.chat_id, text, parse_mode: "HTML", logging: true)

    {:ok, state}
  end
end
