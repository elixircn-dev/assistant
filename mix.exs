defmodule Assistant.MixProject do
  use Mix.Project

  def project do
    [
      app: :assistant,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Assistant.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp dialyzer do
    [
      plt_add_apps: [:iex, :mix]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.2", only: [:test]},
      {:telegex, "~> 1.9.0-rc.0"},
      {:finch, "~> 0.19.0"},
      {:multipart, "~> 0.4.0"},
      {:plug, "~> 1.16"},
      {:remote_ip, "~> 1.2"},
      {:bandit, "~> 1.5"},
      {:typed_struct, "~> 0.3.0"},
      {:gettext, "~> 0.26.1"},
      {:quantum, "~> 3.5.3"},
      {:jason, "~> 1.4.4"},
      {:phoenix_pubsub, "~> 2.1.3"}
    ]
  end
end
