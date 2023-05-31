import Config

if config_env() == :prod do
  # 运行时配置 prod 环境

  # 配置数据目录
  config :assistant, data_dir: System.fetch_env!("ASSISTANT_DATA_DIR")

  # 配置 TG bot 的 token
  config :telegex, token: System.fetch_env!("ASSISTANT_BOT_TOKEN")

  # 配置拥有者的 TG ID
  config :assistant, AssistantBot,
    owner_id: String.to_integer(System.fetch_env!("ASSISTANT_OWNER_ID"))
end
