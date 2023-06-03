defmodule Assistant.HexPm.Client do
  @moduledoc false

  alias Assistant.HexPm.Package

  @type packages_opts :: [page: integer, sort: :updated_at]

  @callback packages(opts :: packages_opts) :: {:ok, [Package.t()]} | {:error, any}

  def packages(opts), do: impl().packages(opts)

  defp impl, do: Application.get_env(:assistant, :hex_pm_client, Assistant.HexPm.ClientImpl)

  @spec last_updated_packages(non_neg_integer) :: {:ok, [Package.t()]} | {:error, any}
  def last_updated_packages(count) do
    case packages(page: 1, sort: :updated_at) do
      {:ok, packages} ->
        {:ok, Enum.take(packages, count)}

      e ->
        e
    end
  end
end
