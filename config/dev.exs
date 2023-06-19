import Config

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter,
  format: "$metadata[$level] $message\n",
  metadata: [:chat_id]

import_config "dev.secret.exs"
