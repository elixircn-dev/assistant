defmodule AssistantBot.Plugs.RespSubscribedCmd do
  @moduledoc false

  use AssistantBot, plug: [commander: :subscribed]

  import Assistant.Subscriptions
  import Assistant.Helper

  # 重写匹配规则，以 `/subscribed` 开始即匹配。
  @impl true
  def match(text, state) do
    if String.starts_with?(text, @command) do
      {:match, action(state, :subscribed)}
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
  def handle(%{text: <<@command <> " repos">>} = _message, state) do
    %{chat_id: chat_id} = state

    ttitle = commands_text("已订阅的仓库列表")

    text = """
    <b>#{ttitle}</b>

    #{render_subscribed_repos(subscribed_repos())}
    """

    send_text(chat_id, text, parse_mode: "HTML", logging: true)

    {:ok, state}
  end

  @impl true
  def handle(%{text: <<@command <> " pkgs">>} = _message, state) do
    %{chat_id: chat_id} = state

    ttitle = commands_text("已订阅的包列表")

    text = """
    <b>#{ttitle}</b>

    #{render_subscribed_pkgs(hex_pm_subscribed_pkgs())}
    """

    send_text(chat_id, text, parse_mode: "HTML", logging: true)

    {:ok, state}
  end

  defp render_subscribed_repos([]) do
    "<code>#{commands_text("空")}</code>"
  end

  defp render_subscribed_repos(subscribed_repos) do
    Enum.map_join(subscribed_repos, "\n", fn repo -> "<code>#{repo}</code>" end)
  end

  defp render_subscribed_pkgs([]) do
    "<code>#{commands_text("空")}</code>"
  end

  defp render_subscribed_pkgs(subscribed_pkgs) do
    Enum.map_join(subscribed_pkgs, "\n", fn pkg -> "<code>#{pkg}</code>" end)
  end
end
