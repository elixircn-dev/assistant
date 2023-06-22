defmodule AssistantBot.RespStartChain do
  @moduledoc false

  use AssistantBot.Chain, {:command, :start}

  # 重写匹配规则，不匹配非私聊消息。
  @impl true
  def match?(%{chat: %{type: chat_type}}, _context) when chat_type != "private" do
    false
  end

  # 重写匹配规则，以 `/start` 开始即匹配。
  @impl true
  def match?(%{text: text}, _context) do
    String.starts_with?(text, @command)
  end

  @impl true
  def handle(_message, context) do
    thello = commands_text("你好，我是来自 %{chat_link} 的开源机器人助理", chat_link: "@elixircn_dev")

    tdetais =
      commands_text("从%{link}可以了解我的更多细节～",
        link: ~s|<a href="https://github.com/elixircn-dev/assistant">这里</a>|
      )

    text = """
    #{thello} 😋

    #{tdetais}
    """

    send_text(context.chat_id, text, parse_mode: "HTML", logging: true)

    {:ok, context}
  end
end
