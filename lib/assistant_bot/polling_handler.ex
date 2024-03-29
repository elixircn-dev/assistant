defmodule AssistantBot.PollingHandler do
  @moduledoc false

  use Telegex.Polling.GenHandler

  @allowed_updates [
    "message",
    "callback_query"
  ]

  @impl true
  def on_boot do
    # initialize bot infomation
    {:ok, bot} = AssistantBot.init()
    # delete any potential webhook
    {:ok, true} = Telegex.delete_webhook()

    Logger.info("Bot (@#{bot.username()}) is working (polling)")

    # create configuration (can be empty, because there are default values)
    %Telegex.Polling.Config{allowed_updates: @allowed_updates}
    # you must return the `Telegex.Polling.Config` struct ↑
  end

  @impl true
  def on_update(update) do
    # consume the update
    AssistantBot.ChainHandler.call(update, %AssistantBot.ChainContext{bot: Telegex.Instance.bot()})
  end

  @impl true
  def on_failure(_update, {e, stacktrace}) do
    Logger.error(
      "Uncaught Error: #{inspect(exception: e)}\n#{Exception.format(:error, e, stacktrace)}"
    )
  end
end
