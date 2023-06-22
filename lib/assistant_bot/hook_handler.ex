defmodule AssistantBot.HookHandler do
  @moduledoc false

  use Telegex.Hook.Handler

  @impl true
  def on_boot do
    # initialize bot infomation
    {:ok, bot} = AssistantBot.init()
    # read some parameters from your env config
    env_config = Application.get_env(:assistant, __MODULE__)
    # delete the webhook and set it again
    Telegex.delete_webhook()
    # set the webhook (url and secret_token)
    secret_token = Telegex.Tools.gen_secret_token()
    Telegex.set_webhook(env_config[:webhook_url], secret_token: secret_token)

    Logger.info("Bot (@#{bot.username()}) is working (webhook)")

    # specify port for web server
    # port has a default value of 4000, but it may change with library upgrades
    %Telegex.Hook.Config{
      server_port: env_config[:server_port],
      secret_token: secret_token
    }

    # you must return the `Telegex.Hook.Config` struct ↑
  end

  @impl true
  def on_update(update) do
    # consume the update
    AssistantBot.ChainHandler.call(update, %AssistantBot.ChainContext{bot: Telegex.Instance.me()})
  end
end
