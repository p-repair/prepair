defmodule PrepairLandingPage.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :prepair_landing_page,
      version: @version <> dev(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Tools
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: cli_env()
    ]
  end

  def application do
    [
      mod: {PrepairLandingPage.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Project dependencies
      {:finch, "~> 0.13"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:phoenix, "~> 1.7.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_view, "~> 0.18.16"},
      {:plug_cowboy, "~> 2.5"},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},

      # Build dependencies
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},

      # Release dependencies
      {:observer_cli, "~> 1.3", only: :prod},

      # Development and test dependencies
      {:ex_check, "~> 0.11.0", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:excoveralls, ">= 0.0.0", only: :test, runtime: false},
      {:phoenix_live_reload, "~> 1.2", only: :dev},

      # Documentation dependencies
      {:ex_doc, "~> 0.19", only: :docs, runtime: false}
    ]
  end

  # Dialyzer configuration
  defp dialyzer do
    [
      plt_add_deps: :app_tree,
      flags: [
        :unmatched_returns,
        :error_handling,
        :race_conditions
      ],
      ignore_warnings: ".dialyzer_ignore"
    ]
  end

  defp cli_env do
    [
      # Use a custom env for docs.
      docs: :docs
    ]
  end

  defp aliases do
    [
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing"
      ]
    ]
  end

  # Helper to add a development revision to the version. Do NOT make a call to
  # Git this way in a production release!!
  def dev do
    with {rev, 0} <-
           System.cmd("git", ["rev-parse", "--short", "HEAD"],
             stderr_to_stdout: true
           ),
         {status, 0} <- System.cmd("git", ["status", "--porcelain"]) do
      status = if status == "", do: "", else: "-dirty"
      "-dev+" <> String.trim(rev) <> status
    else
      _ -> "-dev"
    end
  end
end
