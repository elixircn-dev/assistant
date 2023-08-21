defmodule AssistantBot.RespUnSubscribeChain do
  @moduledoc false

  use AssistantBot.Chain, {:command, :unsubscribe}

  alias Assistant.EasyStore

  import Assistant.Subscriptions
  import Assistant.GitHub.Client, only: [unsubscribe: 2]

  @subscribed_repos_key :subscribed_repos

  # 重写匹配规则，以 `/unsubscribe` 开始即匹配。
  @impl true
  def match?(%{text: text} = _message, _context) do
    String.starts_with?(text, @command)
  end

  # 直接删除非拥有者的消息。
  @impl true
  def handle(message, %{from_owner: false} = context) do
    Telegex.delete_message(message.chat.id, message.message_id)

    {:ok, context}
  end

  @impl true
  def handle(%{text: <<@command <> " repo " <> full_name::binary>>} = _message, context) do
    %{chat_id: chat_id} = context

    full_name = String.trim(full_name)

    [owner, repo | _rest] = String.split(full_name, "/")

    case unsubscribe(owner, repo) do
      {:ok, _} ->
        :ok = EasyStore.list_remove(@subscribed_repos_key, full_name)

        send_text(chat_id, commands_text("已取消订阅。"), logging: true)

      {:error, 404} ->
        :ok = EasyStore.list_remove(@subscribed_repos_key, full_name)

        send_text(chat_id, commands_text("已取消订阅。"), logging: true)

      {:error, reason} ->
        text =
          commands_text("取消订阅失败，原因：%{reason}。",
            reason: "<code>#{Telegex.Tools.safe_html(inspect(reason))}</code>"
          )

        send_text(chat_id, text, parse_mode: "HTML", logging: true)
    end

    {:ok, context}
  end

  @impl true
  def handle(%{text: <<@command <> " pkgs " <> args_text::binary>>} = _message, context) do
    %{chat_id: chat_id} = context

    _ = args_text |> parse_args() |> Enum.map(&remove_hex_pm_package/1)

    send_text(chat_id, commands_text("取消订阅成功。"), logging: true)

    {:ok, context}
  end

  @impl true
  def handle(_message, context) do
    %{chat_id: chat_id} = context

    tunkown_args = commands_text("未知的参数，本命令格式如下：")

    text = """
    #{tunkown_args}

    - <code>/unsubscribe repo [repo_full_name]</code>
    - <code>/unsubscribe pkgs [package_name1] [package_name2] ...</code>
    """

    send_text(chat_id, text, parse_mode: "HTML", logging: true)

    {:ok, context}
  end

  defp parse_args(args_text) do
    # 按照空白字符分割并忽略空内容
    args_text |> String.split(~r/\s+/) |> Enum.reject(&(&1 == ""))
  end
end
