defmodule ExMetalSample.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zacky1972/ex_metal_sample"

  def project do
    [
      app: :ex_metal_sample,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExMetalSample",
      source_url: @source_url,
      docs: [
        main: "ExMetalSample",
        extras: ["README.md"]
      ],
      compilers: [:elixir_make] ++ Mix.compilers(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "Makefile",
        "c_src/*.c",
        "c_src/*.h"
      ]
    ]
  end
end
