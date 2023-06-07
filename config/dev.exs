import Config

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "$metadata[$level] $message\n",
  metadata: [:chat_id]

config :telegex, Telegex.Caller, adapter: Telegex.Caller.HTTPoisonAdapter

import_config "dev.secret.exs"
