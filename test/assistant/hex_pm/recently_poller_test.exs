defmodule Assistant.HexPm.RecentlyPollerTest do
  use ExUnit.Case

  import Assistant.Factory
  import Assistant.HexPm.RecentlyPoller

  alias Assistant.HexPm.MockClient

  test "new_packages/4" do
    Application.put_env(:assistant, :hex_pm_client, MockClient)

    Mox.defmock(MockClient, for: Assistant.HexPm.Client)
    Mox.expect(MockClient, :packages, fn _ -> build(:packages) end)
    Mox.expect(MockClient, :packages, fn _ -> build(:upgraded_packages) end)
    Mox.expect(MockClient, :packages, fn _ -> build(:upgraded_packages) end)

    assert new_packages(build(:skus)) ==
             {:ok,
              [
                %Assistant.HexPm.Package{
                  version: "0.7.1",
                  description: "E2E reactivity for Svelte and LiveView",
                  name: "live_svelte"
                },
                %Assistant.HexPm.Package{
                  version: "0.0.1",
                  description: "Easy file uploads for Elixir/Phoenix",
                  name: "dropkick"
                }
              ], ["dropkick@0.0.1", "live_svelte@0.7.1"]}

    # 第二次调用时 `phoenix_ecto` 库会升级为 `4.4.3`，并更换位置（位于第一个）。
    # 当只用一个 sku 来比对时（如 `phoenix_ecto@4.4.2`），就会导致无限递归发生，但是双重 sku 可以保证正确返回避免这种状况。
    assert new_packages(build(:skus)) ==
             {:ok,
              [
                %Assistant.HexPm.Package{
                  version: "0.7.1",
                  description: "E2E reactivity for Svelte and LiveView",
                  name: "live_svelte"
                },
                %Assistant.HexPm.Package{
                  version: "0.0.1",
                  description: "Easy file uploads for Elixir/Phoenix",
                  name: "dropkick"
                },
                %Assistant.HexPm.Package{
                  version: "4.4.3",
                  description: "Integration between Phoenix & Ecto",
                  name: "phoenix_ecto"
                }
              ], ["phoenix_ecto@4.4.3", "dropkick@0.0.1"]}

    # 当只有一个新版本包时，也可以正确返回 skus。
    assert new_packages(["dropkick@0.0.1", "live_svelte@0.7.1"]) ==
             {:ok,
              [
                %Assistant.HexPm.Package{
                  version: "4.4.3",
                  description: "Integration between Phoenix & Ecto",
                  name: "phoenix_ecto"
                }
              ], ["phoenix_ecto@4.4.3", "dropkick@0.0.1"]}
  end
end
