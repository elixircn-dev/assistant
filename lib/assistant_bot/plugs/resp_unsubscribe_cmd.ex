defmodule AssistantBot.Plugs.RespUnSubscribeRepoCmd do
  @moduledoc false

  use AssistantBot, plug: [commander: :unsubscribe_repo]

  alias Assistant.EasyStore

  import Assistant.GitHub.Client, only: [unsubscribe: 2]

  @subscribed_repos_key :subscribed_repos

  # 重写匹配规则，以 `/subscribe_repo` 开始即匹配。
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
  def handle(%{text: <<@command <> full_name::binary>>} = _message, state) do
    %{chat_id: chat_id} = state

    full_name = String.trim(full_name)

    [owner, repo] = String.split(full_name, "/")

    case unsubscribe(owner, repo) do
      {:ok, _} ->
        :ok = EasyStore.list_remove(@subscribed_repos_key, full_name)

        send_text(chat_id, commands_text("已取消订阅。"), logging: true)

      {:error, reason} ->
        text =
          commands_text("取消订阅失败，原因：%{reason}。",
            reason: "<code>#{Telegex.Tools.safe_html(inspect(reason))}</code>"
          )

        send_text(chat_id, text, parse_mode: "HTML", logging: true)
    end

    {:ok, state}
  end
end
