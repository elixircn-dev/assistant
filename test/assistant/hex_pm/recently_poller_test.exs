defmodule Assistant.HexPm.RecentlyPollerTest do
  use ExUnit.Case

  import Assistant.Factory
  import Assistant.HexPm.RecentlyPoller

  alias Assistant.HexPm.MockClient

  test "get_packages/4" do
    Application.put_env(:assistant, :hex_pm_client, MockClient)

    Mox.defmock(MockClient, for: Assistant.HexPm.Client)
    Mox.expect(MockClient, :packages, fn _ -> build(:packages) end)
    Mox.expect(MockClient, :packages, fn _ -> build(:upgraded_packages) end)

    assert get_packages(build(:skus)) ==
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
              ]}

    # 第二次调用时 `phoenix_ecto` 库会升级为 `4.4.3`，并更换位置（位于第一个）
    # 正确的情况 `get_packages` 会发现这种变化，这是用双重 sku 来保证的效果。
    assert get_packages(build(:skus)) ==
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
              ]}
  end
end
