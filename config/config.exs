import Config

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :chat_id]

# 配置默认语言
config :assistant, Assistant.Gettext, default_locale: "zh"

# 配置数据目录
config :assistant, data_dir: "data"

# 配置定时任务
config :assistant, Assistant.Scheduler,
  jobs: [
    # Every 15 minutes
    {"*/15 * * * *", &Assistant.Forum.Checker.run/0}
  ]

# 配置 Telegex。
config :telegex,
  caller_adapter: {Finch, [receive_timeout: 5 * 1000]},
  hook_adapter: Bandit

import_config "#{config_env()}.exs"
