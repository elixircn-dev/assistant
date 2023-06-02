defmodule AssistantBot.Plugs.RespSubscribedReposCmd do
  @moduledoc false

  use AssistantBot, plug: [commander: :subscribed_repos]

  import Assistant.Helper

  # 直接删除非拥有者的消息。
  @impl true
  def handle(message, %{from_owner: false} = state) do
    Telegex.delete_message(message.chat.id, message.message_id)

    {:ok, state}
  end

  @impl true
  def handle(_message, state) do
    %{chat_id: chat_id} = state

    text = """
    <b>已订阅的仓库列表</b>

    #{render_subscribed_repos(subscribed_repos())}
    """

    send_text(chat_id, text, parse_mode: "HTML", logging: true)

    {:ok, state}
  end

  defp render_subscribed_repos([]) do
    "<code>空</code>"
  end

  defp render_subscribed_repos(subscribed_repos) do
    Enum.map_join(subscribed_repos, "\n", fn repo -> "<code>#{repo}</code>" end)
  end
end
