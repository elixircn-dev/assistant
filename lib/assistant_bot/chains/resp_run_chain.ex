defmodule AssistantBot.RespRunChain do
  @moduledoc false

  use AssistantBot.Chain, {:command, :run}

  # 重写匹配规则，以 `/run` 开始即匹配。
  @impl true
  def match?(%{text: text}, _context) do
    String.starts_with?(text, @command)
  end

  # 直接删除非拥有者的消息。
  @impl true
  def handle(message, %{from_owner: false} = context) do
    Telegex.delete_message(message.chat.id, message.message_id)

    {:ok, context}
  end

  @impl true
  def handle(%{text: <<@command <> task_name::binary>>} = _message, context) do
    %{chat_id: chat_id} = context

    task_name = String.trim(task_name)

    case task_name do
      "pinned_forum_topics" ->
        Assistant.Forum.Checker.run()

        send_text(chat_id, commands_text("执行结束。"), logging: true)

      _ ->
        text = commands_text("未知的运行目标: %{target_name}。", target_name: "<code>#{task_name}</code>")

        send_text(chat_id, text, parse_mode: "HTML", logging: true)
    end

    {:ok, context}
  end
end
