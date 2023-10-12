import Config

if config_env() == :prod do
  # 运行时配置 prod 环境

  # 配置数据目录
  config :assistant, data_dir: System.fetch_env!("ASSISTANT_DATA_DIR")

  # 配置 GitHub token
  config :assistant, github_token: System.fetch_env!("ASSISTANT_GITHUB_TOKEN")

  config :telegex,
    # 配置 bot 的 token。
    token: System.fetch_env!("ASSISTANT_BOT_TOKEN"),
    # 配置 bot 的 API 地址。
    api_base_url: System.get_env("ASSISTANT_BOT_API_BASE_URL") || "https://api.telegram.org/bot"

  # 配置 bot 的工作模式
  config :assistant, AssistantBot, work_mode: :webhook

  # 配置 webhook 模式
  config :assistant, AssistantBot.HookHandler,
    webhook_url: System.fetch_env!("ASSISTANT_BOT_WEBHOOK_URL"),
    server_port: System.fetch_env!("ASSISTANT_BOT_WEBHOOK_PORT")

  config :assistant, AssistantBot,
    # 配置拥有者的 TG ID
    owner_id: String.to_integer(System.fetch_env!("ASSISTANT_OWNER_ID")),
    # 配置群组的 TG ID
    group_id: String.to_integer(System.fetch_env!("ASSISTANT_GROUP_ID"))
end
