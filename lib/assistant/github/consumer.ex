defmodule Assistant.GitHub.Consumer do
  @moduledoc false

  use Assistant.PubSub

  import Assistant.Helper
  import Assistant.GitHub.Client

  require Logger

  def dispatch(%{"repository" => %{"full_name" => full_name}} = notification) do
    subscribed? = Enum.member?(subscribed_repos(), full_name)

    if subscribed? do
      Logger.debug(
        "[github] Dispatch notification for subscribed repositorie: #{inspect(full_name: full_name)}"
      )

      # 派发已订阅仓库的通知
      _dispatch(notification)

      :ok
    else
      Logger.debug(
        "[github] Ignore notification for unsubscribed repositorie: #{inspect(full_name: full_name)}"
      )

      :ignored
    end
  end

  def dispatch(_), do: :unkown_repo

  def _dispatch(%{"subject" => %{"type" => "Release"}} = notification) do
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

  def _dispatch(%{"subject" => %{"type" => subject_type}} = _notification) do
    # 忽略的通知主题
    Logger.debug("[github] Ignore notification subject: #{inspect(type: subject_type)}")

    :ignored
  end
end
