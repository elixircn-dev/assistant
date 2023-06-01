defmodule Assistant.GitHub.Consumer do
  @moduledoc false

  use Assistant.PubSub

  require Logger

  def dispatch(%{"subject" => %{"type" => "Release"}} = notification) do
    subject_url = notification["subject"]["url"]
    <<"https://api.github.com" <> subject_path::binary>> = subject_url

    case Assistant.GitHub.NotificationsPoller.call(:get, subject_path) do
      {:ok, subject} ->
        :ok = broadcast("github", {:repo_release, {notification, subject}})

        :ok

      {:error, reason} ->
        Logger.error(
          "[github] Call `subject_url` failed: #{inspect(path: subject_path, reason: reason)}"
        )

        :ignored
    end
  end

  def dispatch(_), do: :ignored
end
