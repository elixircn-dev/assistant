import Config

# Do not print debug messages in production
config :logger, :default_handler, level: :debug

# 配置进程
config :assistant, Assistant.Application, runtime_migrate: true, tg_serve: true
