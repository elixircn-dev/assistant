defmodule Assistant.Subscriptions do
  @moduledoc false

  alias Assistant.EasyStore

  @hex_pm_subscribed_pkgs_key :hex_pm_subscribed_pkgs

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
end
