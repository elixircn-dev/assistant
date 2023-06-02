defmodule Assistant.GitHub.Consumer do
  @moduledoc false

  use Assistant.PubSub

  import Assistant.GitHub.Client

  require Logger

  def dispatch(%{"subject" => %{"type" => "Release"}} = notification) do
    subject_url = notification["subject"]["url"]

    case call(:get, subject_url) do
      {:ok, subject} ->
        :ok = broadcast("github", {:repo_release, {notification, subject}})

        :ok

      {:error, reason} ->
        Logger.error(
          "[github] Call `subject_url` failed: #{inspect(subject_url: subject_url, reason: reason)}"
        )

        :ignored
    end
  end

  def dispatch(_), do: :ignored
end
