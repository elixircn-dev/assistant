defmodule Assistant.GitHub.Notification do
  @moduledoc false

  # TODO: 将 Notification 和 Subject 转换为真实结构并重构相关代码。

  def key(notification) do
    "repo-" <> notification["repository"]["full_name"]
  end

  def render_message_text(push_count, notification, subject) when push_count <= 3 do
    full_name = notification["repository"]["full_name"]
    repo_description = notification["repository"]["description"]
    tag_url = subject["html_url"]
    tag_name = subject["tag_name"]

    """
    #{full_name} <a href="#{tag_url}">#{Telegex.Tools.safe_html(tag_name)}</a>

    <i>#{Telegex.Tools.safe_html(repo_description)}</i>
    """
  end

  def render_message_text(_push_count, notification, subject) do
    full_name = notification["repository"]["full_name"]
    tag_url = subject["html_url"]
    tag_name = subject["tag_name"]

    """
    #{full_name} <a href="#{tag_url}">#{Telegex.Tools.safe_html(tag_name)}</a>
    """
  end
end
