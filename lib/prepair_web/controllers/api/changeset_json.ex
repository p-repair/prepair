defmodule PrepairWeb.Api.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    # Maps are encodable to JSON objects. So we just pass it forward.
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(PrepairWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PrepairWeb.Gettext, "errors", msg, opts)
    end
  end
end
