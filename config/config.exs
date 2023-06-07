import Config

# Configures Elixir's Logger
config :logger, :console,
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

# 配置 Telegex 的 HTTP 客户端适配器
config :telegex, Telegex.Caller, adapter: Telegex.Caller.HTTPoisonAdapter

import_config "#{config_env()}.exs"
