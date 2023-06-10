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
    url = url(package)
    doc_url = doc_url(package)

    """
    <b><u>Package Updated</u></b>

    <a href="#{url}"><b>#{Telegex.Tools.safe_html(package.name)}</b></a> <i>#{Telegex.Tools.safe_html(package.description)}</i>

    v#{Telegex.Tools.safe_html(package.version)}

    <a href="#{doc_url}">阅读文档</a>
    """
  end
end
