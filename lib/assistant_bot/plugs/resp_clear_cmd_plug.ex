defmodule AssistantBot.RespClearCmdPlug do
  @moduledoc false

  use AssistantBot, plug: [commander: :clear]

  alias Assistant.EasyStore

  @subscribed_repos_key :subscribed_repos

  # 重写匹配规则，以 `/clear` 开始即匹配。
  @impl true
  def match(text, state) do
    if String.starts_with?(text, @command) do
      {:match, state}
    else
      {:nomatch, state}
    end
  end

  # 直接删除非拥有者的消息。
  @impl true
  def handle(message, %{from_owner: false} = state) do
    Telegex.delete_message(message.chat.id, message.message_id)

    {:ok, state}
  end

  @impl true
  def handle(%{text: <<@command <> task_name::binary>>} = _message, state) do
    %{chat_id: chat_id} = state

    task_name = String.trim(task_name)

    case task_name do
      "pinned_forum_topics" ->
        :ok = EasyStore.delete(:pinned_forum_topics)

        send_text(chat_id, commands_text("已清理论坛置顶主题缓存。"), logging: true)

      "subscribed_repos" ->
        :ok = EasyStore.delete(@subscribed_repos_key)

        send_text(chat_id, commands_text("已经清理所有订阅仓库。"), logging: true)

      _ ->
        text = commands_text("未知的清理目标: %{target_name}。", target_name: "<code>#{task_name}</code>")

        send_text(chat_id, text, parse_mode: "HTML", logging: true)
    end

    {:ok, state}
  end
end
