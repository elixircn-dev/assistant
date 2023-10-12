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

  @spec render_message_text(:publish, __MODULE__.t()) :: String.t()
  def render_message_text(:publish, package) do
    """
    <b>Updated</b> <a href="#{url(package)}"><b>#{Telegex.Tools.safe_html(package.name)}</b></a> to v#{Telegex.Tools.safe_html(package.version)}

    <i>#{Telegex.Tools.safe_html(package.description)}</i>

    <a href="#{doc_url(package)}">Document</a>
    """
  end
end
