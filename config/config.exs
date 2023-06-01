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
    {"*/15 * * * *", &Assistant.ForumChecker.run/0}
  ]

import_config "#{config_env()}.exs"
