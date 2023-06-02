defmodule Assistant.Helper do
  @moduledoc false

  use Assistant.I18n

  alias Assistant.EasyStore

  @subscribed_repos_key :subscribed_repos

  def elapsed_time(target_dt) do
    dt_now = DateTime.utc_now()
    minutes = DateTime.diff(dt_now, target_dt, :minute)

    if minutes < 60 do
      commands_text("%{count} 分钟之前", count: minutes)
    else
      hours = DateTime.diff(dt_now, target_dt, :hour)

      if hours < 24 do
        commands_text("%{count} 小时之前", count: hours)
      else
        days = DateTime.diff(dt_now, target_dt, :day)

        commands_text("%{count} 天之前", count: days)
      end
    end
  end

  def subscribed_repos do
    EasyStore.get(@subscribed_repos_key, [])
  end
end
