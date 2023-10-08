defmodule Prepair.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :prepair,
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
      mod: {Prepair.Application, []},
      extra_applications: [:logger, :runtime_tools, :gen_smtp]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Project dependencies
      {:bcrypt_elixir, "~> 3.0"},
      {:ecto_sql, "~> 3.6"},
      {:finch, "~> 0.13"},
      {:gen_smtp, "~> 1.1"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:mailerlite, "~> 0.3.0"},
      {:phoenix, "~> 1.7.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:phoenix_live_view, "~> 0.19.4"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.2.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:typed_ecto_schema, "~> 0.4.1"},

      # Build dependencies
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},

      # Release dependencies
      {:observer_cli, "~> 1.3", only: :prod},

      # Development and test dependencies
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_check, "~> 0.15.0", only: :dev, runtime: false},
      {:excoveralls, ">= 0.0.0", only: :dev, runtime: false},
      {:floki, ">= 0.30.0", only: :test},
      {:mix_test_watch, ">= 0.0.0", only: :test, runtime: false},
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
      docs: :docs,
      "test.watch": :test,

      # Always run coveralls mix tasks in `:test` env.
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.html": :test
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
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
