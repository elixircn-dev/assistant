defmodule Assistant.HexPm.Client do
  @moduledoc false

  alias Assistant.HexPm.Package

  @type packages_opts :: [page: non_neg_integer, sort: :updated_at]

  @callback packages(opts :: packages_opts) :: {:ok, [Package.t()]} | {:error, any}

  @spec packages(packages_opts) :: {:ok, [Package.t()]} | {:error, any}
  def packages(opts), do: impl().packages(opts)

  @spec new_packages([String.t()], integer, list, list) ::
          {:ok, [Package.t()], [String.t()]} | {:error, any}
  def new_packages(skus, page \\ 1, all \\ [], new \\ []) do
    append_fun = fn p, new ->
      psku = Package.sku(p)

      cond do
        match?([^psku, _], skus) ->
          # 与最新的 sku 匹配，停止迭代
          {:halt, new}

        match?([_, ^psku], skus) ->
          # 与第二个 sku 匹配，停止迭代
          # 达到此处是因为最新的 sku 关联包升级了，达到第二个匹配的 sku，相当于第二重保证
          # 假设在一个周期内，两个 sku 相关的包都升级了，就会出现无限递扫描包的情况，但发生机率非常小。如果发生，可以用更多数量的 sku 来保证
          {:halt, new}

        true ->
          {:cont, new ++ [p]}
      end
    end

    case packages(page: page, sort: :updated_at) do
      {:ok, packages} ->
        all = all ++ packages

        new = Enum.reduce_while(packages, new, append_fun)

        cond do
          Enum.empty?(packages) ->
            {:ok, Enum.reverse(new), gen_skus(all)}

          length(new) < length(all) ->
            {:ok, Enum.reverse(new), gen_skus(all)}

          true ->
            new_packages(skus, page + 1, all, new)
        end

      e ->
        e
    end
  end

  @spec gen_skus([Package.t()]) :: [String.t()]
  def gen_skus([p1, p2 | _]) do
    [Package.sku(p1), Package.sku(p2)]
  end

  defp impl, do: Application.get_env(:assistant, :hex_pm_client, Assistant.HexPm.ClientImpl)
end
