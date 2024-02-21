defmodule UrlShortnerWeb.UrlHTML do
  use UrlShortnerWeb, :html

  embed_templates "url_html/*"

  @doc """
  Renders a url form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def url_form(assigns)
end
