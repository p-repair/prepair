defmodule Prepair.AshDomains.ValidationMacros do
  defmacro validate_email() do
    quote do
      validate match(
                 :email,
                 ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$/
               ) do
        on [:create, :update]
        message dgettext("errors", "must have the @ sign and no spaces")
      end

      validate string_length(:email, max: 160) do
        on [:create, :update]
        message dgettext("errors", "should be at most 160 characters")
      end
    end
  end

  defmacro validate_password() do
    quote do
      validate string_length(:password, min: 8) do
        on [:create, :update]
        message dgettext("errors", "should be at least 8 characters")
      end

      validate string_length(:password, max: 256) do
        on [:create, :update]
        message dgettext("errors", "should be at most 256 characters")
      end

      validate match(:password, ~r/[a-z]/) do
        on [:create, :update]
        message dgettext("errors", "at least one lower case character")
      end

      validate match(:password, ~r/[A-Z]/) do
        on [:create, :update]
        message dgettext("errors", "at least one upper case character")
      end

      validate match(:password, ~r/[!?@#$%^&*_0-9]/) do
        on [:create, :update]

        message dgettext(
                  "errors",
                  "at least one digit or punctuation character"
                )
      end
    end
  end
end
