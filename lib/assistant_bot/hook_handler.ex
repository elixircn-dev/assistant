defmodule AssistantBot.HookHandler do
  @moduledoc false

  use Telegex.Hook.Handler

  alias AssistantBot.Consumer

  @impl true
  def on_boot do
    # 初始化 bot
    AssistantBot.init()
    # read some parameters from your env config
    env_config = Application.get_env(:assistant, __MODULE__)
    # delete the webhook and set it again
    Telegex.delete_webhook()
    # set the webhook (url and secret_token)
    secret_token = Telegex.Tools.gen_secret_token()

    Telegex.set_webhook(env_config[:webhook_url], secret_token: secret_token)
    # specify port for web server
    # port has a default value of 4000, but it may change with library upgrades
    config = %Telegex.Hook.Config{
      server_port: env_config[:server_port],
      secret_token: secret_token
    }

    # you must return the `Telegex.Hook.Config` struct ↑

    Logger.info("Bot (@#{AssistantBot.username()}) works in webhook mode")

    config
  end

  @impl true
  def on_update(update) do
    # consume the update
    Consumer.consume(update)

    :ok
  end
end
