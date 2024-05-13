[
  import_deps: [
    :ash,
    :ash_postgres,
    :ecto,
    :ecto_sql,
    :phoenix
  ],
  plugins: [Phoenix.LiveView.HTMLFormatter, Spark.Formatter],
  inputs: ["*.{ex,exs}", "{config,lib,priv,test}/**/*.{ex,exs,heex}"],
  line_length: 80
]
