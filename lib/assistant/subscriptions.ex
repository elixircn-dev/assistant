defmodule Assistant.Subscriptions do
  @moduledoc false

  alias Assistant.EasyStore

  @hex_pm_subscribed_pkgs_key :hex_pm_subscribed_pkgs
  @github_notifications_offset :github_notifications_offset

  def add_hex_pm_package(pname) do
    # TODO: 检查添加包是否存在。
    EasyStore.list_append(@hex_pm_subscribed_pkgs_key, pname)
  end

  def remove_hex_pm_package(pname) do
    EasyStore.list_remove(@hex_pm_subscribed_pkgs_key, pname)
  end

  def hex_pm_subscribed_pkgs do
    EasyStore.get(@hex_pm_subscribed_pkgs_key, [])
  end

  def clear_hex_pm_subscribed_pkgs do
    EasyStore.delete(@hex_pm_subscribed_pkgs_key)
  end

  def get_github_notifications_offset(default \\ 0) do
    EasyStore.get(@github_notifications_offset, default)
  end

  def put_github_notifications_offset(offset) do
    EasyStore.put(@github_notifications_offset, offset)
  end

  def clear_github_notifications_offset do
    EasyStore.delete(@github_notifications_offset)
  end
end
