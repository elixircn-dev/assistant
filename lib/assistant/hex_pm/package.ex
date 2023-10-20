defmodule Assistant.HexPm.Package do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :description, String.t()
    field :version, String.t(), enforce: true
  end

  def from(map) when is_map(map) do
    %__MODULE__{
      name: map["name"],
      description: map["meta"]["description"],
      version: map["latest_version"]
    }
  end

  def sku(package) do
    "#{package.name}@#{package.version}"
  end

  def url(package), do: "https://hex.pm/packages/#{package.name}"

  def doc_url(package), do: "https://hexdocs.pm/#{package.name}/#{package.version}"

  @spec key(__MODULE__.t()) :: String.t()
  def key(package) when is_struct(package, __MODULE__) do
    "pkg-" <> package.name
  end

  @spec render_message_text(non_neg_integer, __MODULE__.t()) :: String.t()
  def render_message_text(push_count, package) when push_count <= 3 do
    """
    <b>Updated</b> <a href="#{url(package)}">#{Telegex.Tools.safe_html(package.name)}</a> to v#{Telegex.Tools.safe_html(package.version)}

    <i>#{Telegex.Tools.safe_html(package.description)}</i>

    <a href="#{doc_url(package)}">阅读文档</a>
    """
  end

  def render_message_text(_push_count, package) do
    """
    <b>Updated</b> <a href="#{url(package)}">#{Telegex.Tools.safe_html(package.name)}</a> to v#{Telegex.Tools.safe_html(package.version)}
    """
  end
end
