# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

import Config

# ---------------------------------------------------------------------------- #
#                      General application configuration                       #
# ---------------------------------------------------------------------------- #

config :prepair,
  ecto_repos: [Prepair.Repo]

config :prepair,
       PrepairWeb.Gettext,
       default_locale: "en",
       locales: ~w(en fr)

# ---------------------------------------------------------------------------- #
#                            Endpoint configuration                            #
# ---------------------------------------------------------------------------- #

config :prepair, PrepairWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [
      html: PrepairWeb.ErrorHTML,
      json: PrepairWeb.ErrorJSON
    ],
    layout: false
  ],
  pubsub_server: Prepair.PubSub,
  live_view: [signing_salt: "QOrvxyAg"]

# ---------------------------------------------------------------------------- #
#                             Mailer configuration                             #
# ---------------------------------------------------------------------------- #

# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :prepair, Prepair.Mailer, adapter: Swoosh.Adapters.Local

config :prepair, :emails,
  sender: {"(p)repair", "p-repair@ejpcamc.net"},
  admin_contacts: [
    {"Guillaume Cugnet", "guillaume+prepair@cugnet.eu"},
    {"Jean-Philippe Cugnet", "jpc+prepair@ejpcmac.net"}
  ]

# ---------------------------------------------------------------------------- #
#                            Esbuild configuration                             #
# ---------------------------------------------------------------------------- #

# (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# ---------------------------------------------------------------------------- #
#                            Tailwind configuration                            #
# ---------------------------------------------------------------------------- #

# (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# ---------------------------------------------------------------------------- #
#                        Elixir's Logger configuration                         #
# ---------------------------------------------------------------------------- #

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# ---------------------------------------------------------------------------- #
#                         Ash Framework configuration                          #
# ---------------------------------------------------------------------------- #

config :prepair, :ash_domains, [
  Prepair.AshDomains.Accounts,
  Prepair.AshDomains.Newsletter,
  Prepair.AshDomains.Notifications,
  Prepair.AshDomains.Products,
  Prepair.AshDomains.Profiles
]

config :spark, :formatter,
  remove_parens?: true,
  "Ash.Domain": [],
  "Ash.Resource": [
    section_order: [
      # Any section not in this list is left where it is.
      # But these sections will always appear in this order in a resource.
      :postgres,
      :attributes,
      :relationships,
      :identities,
    ]
  ]

# ---------------------------------------------------------------------------- #
#                          API related configurations                          #
# ---------------------------------------------------------------------------- #

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# ---------------------------------------------------------------------------- #
#                      Environment related configurations                      #
# ---------------------------------------------------------------------------- #

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
