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
       },
       %Assistant.HexPm.Package{
         version: "1.20.0",
         description: "Convert the race information obtained from Winticket to a struct.",
         name: "winticket_race_parser"
       },
       %Assistant.HexPm.Package{
         version: "0.3.0",
         description: "HPACK Implementation",
         name: "hpack_erl"
       },
       %Assistant.HexPm.Package{
         version: "0.1.6",
         description: "A Gleam Testing Framework",
         name: "showtime"
       },
       %Assistant.HexPm.Package{
         version: "0.0.1",
         description: "Elixir SDK for Inngest",
         name: "inngest"
       },
       %Assistant.HexPm.Package{
         version: "0.1.0",
         description: "Providing a web interface to interact with mix xref graph output",
         name: "ex_compile_graph"
       },
       %Assistant.HexPm.Package{
         version: "0.7.1",
         description: "The library for managing pools of workers.",
         name: "poolex"
       },
       %Assistant.HexPm.Package{
         version: "0.1.1",
         description: "Elixir RPC over ZeroMQ",
         name: "exzrpc"
       },
       %Assistant.HexPm.Package{
         version: "0.1.2",
         description: "Library for creating language servers",
         name: "gen_lsp"
       },
       %Assistant.HexPm.Package{
         version: "0.3.4",
         description:
           "A wrapper for the PlanetSide 2 API and Event Streaming service for Elixir.",
         name: "planetside_api"
       },
       %Assistant.HexPm.Package{
         version: "0.7.0",
         description:
           "The official Elixir client for Replicate. It lets you run models from your Elixir code, and everything else you can do with Replicate's H...",
         name: "replicate"
       },
       %Assistant.HexPm.Package{
         version: "0.1.0",
         description: "Experimental dev utils for Grizzly. Use at your own risk.",
         name: "grizzly_dev_utils"
       },
       %Assistant.HexPm.Package{
         version: "0.2.0",
         description: "Functions to introspect the Unicode Unihan character database.",
         name: "unicode_unihan"
       },
       %Assistant.HexPm.Package{
         version: "0.4.0",
         description: "An Entity-Component-System framework for Elixir",
         name: "ecsx"
       },
       %Assistant.HexPm.Package{
         version: "0.34.3",
         description:
           "Floki is a simple HTML parser that enables search for nodes using CSS selectors.",
         name: "floki"
       },
       %Assistant.HexPm.Package{
         version: "6.7.0",
         description: "Elixir Z-Wave library",
         name: "grizzly"
       },
       %Assistant.HexPm.Package{
         version: "0.1.1",
         description: "Tools for using Geo, Topo and PostGIS with Ash",
         name: "ash_geo"
       },
       %Assistant.HexPm.Package{
         version: "0.6.1",
         description: "A Markdown component for Surface",
         name: "surface_markdown"
       },
       %Assistant.HexPm.Package{
         version: "2.9.19",
         description:
           "A resource declaration and interaction library. Built with pluggable data layers, and\ndesigned to be used by multiple front ends.",
         name: "ash"
       },
       %Assistant.HexPm.Package{
         version: "0.3.0",
         description: "Run TypeScript & JavaScript files right from Elixir.",
         name: "deno_ex"
       },
       %Assistant.HexPm.Package{
         version: "0.7.12",
         description: "A code-style enforcer that will just FIFY instead of complaining",
         name: "styler"
       },
       %Assistant.HexPm.Package{
         version: "0.13.0",
         description: "Contentful sync API client for Elixir.",
         name: "cf_sync"
       },
       %Assistant.HexPm.Package{
         version: "0.2.2",
         description: "Phoenix components for Phosphoricons!",
         name: "phosphoricons"
       },
       %Assistant.HexPm.Package{
         version: "0.11.2",
         description: "Gleam command line argument parsing with basic flag support.",
         name: "glint"
       },
       %Assistant.HexPm.Package{
         version: "0.12.0",
         description: "A set of functions to deal with analytical formulae.",
         name: "formulae"
       },
       %Assistant.HexPm.Package{
         version: "0.5.3",
         description: "Phoenix components for Heroicons!",
         name: "heroicons"
       },
       %Assistant.HexPm.Package{
         version: "0.7.7",
         description: "A pure-Elixir HTTP server built for Plug & WebSock apps",
         name: "bandit"
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
       },
       %Assistant.HexPm.Package{
         version: "1.20.0",
         description: "Convert the race information obtained from Winticket to a struct.",
         name: "winticket_race_parser"
       },
       %Assistant.HexPm.Package{
         version: "0.3.0",
         description: "HPACK Implementation",
         name: "hpack_erl"
       },
       %Assistant.HexPm.Package{
         version: "0.1.6",
         description: "A Gleam Testing Framework",
         name: "showtime"
       },
       %Assistant.HexPm.Package{
         version: "0.0.1",
         description: "Elixir SDK for Inngest",
         name: "inngest"
       },
       %Assistant.HexPm.Package{
         version: "0.1.0",
         description: "Providing a web interface to interact with mix xref graph output",
         name: "ex_compile_graph"
       },
       %Assistant.HexPm.Package{
         version: "0.7.1",
         description: "The library for managing pools of workers.",
         name: "poolex"
       },
       %Assistant.HexPm.Package{
         version: "0.1.1",
         description: "Elixir RPC over ZeroMQ",
         name: "exzrpc"
       },
       %Assistant.HexPm.Package{
         version: "0.1.2",
         description: "Library for creating language servers",
         name: "gen_lsp"
       },
       %Assistant.HexPm.Package{
         version: "0.3.4",
         description:
           "A wrapper for the PlanetSide 2 API and Event Streaming service for Elixir.",
         name: "planetside_api"
       },
       %Assistant.HexPm.Package{
         version: "0.7.0",
         description:
           "The official Elixir client for Replicate. It lets you run models from your Elixir code, and everything else you can do with Replicate's H...",
         name: "replicate"
       },
       %Assistant.HexPm.Package{
         version: "0.1.0",
         description: "Experimental dev utils for Grizzly. Use at your own risk.",
         name: "grizzly_dev_utils"
       },
       %Assistant.HexPm.Package{
         version: "0.2.0",
         description: "Functions to introspect the Unicode Unihan character database.",
         name: "unicode_unihan"
       },
       %Assistant.HexPm.Package{
         version: "0.4.0",
         description: "An Entity-Component-System framework for Elixir",
         name: "ecsx"
       },
       %Assistant.HexPm.Package{
         version: "0.34.3",
         description:
           "Floki is a simple HTML parser that enables search for nodes using CSS selectors.",
         name: "floki"
       },
       %Assistant.HexPm.Package{
         version: "6.7.0",
         description: "Elixir Z-Wave library",
         name: "grizzly"
       },
       %Assistant.HexPm.Package{
         version: "0.1.1",
         description: "Tools for using Geo, Topo and PostGIS with Ash",
         name: "ash_geo"
       },
       %Assistant.HexPm.Package{
         version: "0.6.1",
         description: "A Markdown component for Surface",
         name: "surface_markdown"
       },
       %Assistant.HexPm.Package{
         version: "2.9.19",
         description:
           "A resource declaration and interaction library. Built with pluggable data layers, and\ndesigned to be used by multiple front ends.",
         name: "ash"
       },
       %Assistant.HexPm.Package{
         version: "0.3.0",
         description: "Run TypeScript & JavaScript files right from Elixir.",
         name: "deno_ex"
       },
       %Assistant.HexPm.Package{
         version: "0.7.12",
         description: "A code-style enforcer that will just FIFY instead of complaining",
         name: "styler"
       },
       %Assistant.HexPm.Package{
         version: "0.13.0",
         description: "Contentful sync API client for Elixir.",
         name: "cf_sync"
       },
       %Assistant.HexPm.Package{
         version: "0.2.2",
         description: "Phoenix components for Phosphoricons!",
         name: "phosphoricons"
       },
       %Assistant.HexPm.Package{
         version: "0.11.2",
         description: "Gleam command line argument parsing with basic flag support.",
         name: "glint"
       },
       %Assistant.HexPm.Package{
         version: "0.12.0",
         description: "A set of functions to deal with analytical formulae.",
         name: "formulae"
       },
       %Assistant.HexPm.Package{
         version: "0.5.3",
         description: "Phoenix components for Heroicons!",
         name: "heroicons"
       },
       %Assistant.HexPm.Package{
         version: "0.7.7",
         description: "A pure-Elixir HTTP server built for Plug & WebSock apps",
         name: "bandit"
       }
     ]}
  end
end
