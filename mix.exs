defmodule Dracula.Mixfile do
  use Mix.Project

  def project do
    [
      app: :dracula,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
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
      {:earmark, github: "jeffkreeftmeijer/earmark", branch: "heading-anchors"}
    ]
  end
end
