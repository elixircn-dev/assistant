defmodule Assistant.HexPm.Package do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :description, String.t()
    field :version, String.t(), enforce: true
  end

  def from(node) do
    name = node |> Floki.find("a") |> Floki.text()
    description = node |> Floki.find("p") |> Floki.text()
    version = node |> Floki.find("span.version") |> Floki.text()

    %__MODULE__{name: name, description: description, version: version}
  end

  def sku(package) do
    "#{package.name}@#{package.version}"
  end

  def url(package), do: "https://hex.pm/packages/#{package.name}"

  def doc_url(package), do: "https://hexdocs.pm/#{package.name}/#{package.version}"
end
