defmodule Assistant.Factory do
  @moduledoc false

  def build(:skus) do
    [
      Assistant.HexPm.Package.sku(%{
        version: "4.4.2",
        name: "phoenix_ecto"
      }),
      Assistant.HexPm.Package.sku(%{
        version: "3.2.1",
        name: "smppex"
      })
    ]
  end

  def build(:packages) do
    {:ok,
     [
       %Assistant.HexPm.Package{
         version: "0.0.1",
         description: "Easy file uploads for Elixir/Phoenix",
         name: "dropkick"
       },
       %Assistant.HexPm.Package{
         version: "0.7.1",
         description: "E2E reactivity for Svelte and LiveView",
         name: "live_svelte"
       },
       %Assistant.HexPm.Package{
         version: "4.4.2",
         description: "Integration between Phoenix & Ecto",
         name: "phoenix_ecto"
       },
       %Assistant.HexPm.Package{
         version: "3.2.1",
         description: "SMPP 3.4 protocol and framework implemented in Elixir",
         name: "smppex"
       }
     ]}
  end

  def build(:upgraded_packages) do
    {:ok,
     [
       %Assistant.HexPm.Package{
         version: "4.4.3",
         description: "Integration between Phoenix & Ecto",
         name: "phoenix_ecto"
       },
       %Assistant.HexPm.Package{
         version: "0.0.1",
         description: "Easy file uploads for Elixir/Phoenix",
         name: "dropkick"
       },
       %Assistant.HexPm.Package{
         version: "0.7.1",
         description: "E2E reactivity for Svelte and LiveView",
         name: "live_svelte"
       },
       %Assistant.HexPm.Package{
         version: "3.2.1",
         description: "SMPP 3.4 protocol and framework implemented in Elixir",
         name: "smppex"
       }
     ]}
  end
end
