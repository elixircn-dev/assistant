defmodule Assistant.MixProject do
  use Mix.Project

  def project do
    [
      app: :assistant,
      version: "0.1.0",
      elixir: "~> 1.14",
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
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:telegex, "~> 0.1"},
      {:telegex_plug, "~> 0.3"},
      {:typed_struct, "~> 0.2"},
      {:gettext, "~> 0.22"}
    ]
  end
end
