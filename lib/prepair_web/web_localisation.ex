defmodule PrepairWeb.Localisation do
  import Plug.Conn

  @locales Gettext.known_locales(PrepairWeb.Gettext)

  def set_web_localisation(conn, _opts) do
    locale = fetch_locale(conn)
    Gettext.put_locale(locale)

    # NOTE: Let’s put the locale in the session so that the `on_mount` hook can
    # get it and put the locale for the LiveView process.
    conn |> put_session(:locale, locale)
  end

  def on_mount(:default, _params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(locale)
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket), do: {:cont, socket}

  defp fetch_locale(conn) do
    case locale_from_params(conn) || locale_from_cookies(conn) ||
           locale_from_header(conn) do
      # NOTE: If nil, fallback to the default locale set in `config.exs`
      nil -> Gettext.get_locale()
      locale -> locale
    end
  end

  defp locale_from_params(conn) do
    conn.params["locale"] |> validate_locale()
  end

  defp locale_from_cookies(conn) do
    conn.cookies["locale"] |> validate_locale()
  end

  defp validate_locale(locale) when locale in @locales, do: locale
  defp validate_locale(_locale), do: nil

  # Taken from set_locale plug written by Gerard de Brieder
  # https://github.com/smeevil/set_locale/blob/fd35624e25d79d61e70742e42ade955e5ff857b8/lib/headers.ex
  defp locale_from_header(conn) do
    conn
    |> extract_accept_language
    |> Enum.find(nil, fn accepted_locale ->
      Enum.member?(@locales, accepted_locale)
    end)
  end

  defp extract_accept_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> ensure_language_fallbacks()

      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures =
      Regex.named_captures(
        ~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i,
        string
      )

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp ensure_language_fallbacks(tags) do
    Enum.flat_map(tags, fn tag ->
      [language | _] = String.split(tag, "-")
      if Enum.member?(tags, language), do: [tag], else: [tag, language]
    end)
  end
end
