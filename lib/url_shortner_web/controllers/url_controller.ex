defmodule UrlShortnerWeb.UrlController do
  use UrlShortnerWeb, :controller

  alias UrlShortner.Url

  def new(conn, _params) do
    changeset = UrlShortner.change_url(%Url{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"url" => url_params}) do
    case UrlShortner.create_url(url_params) do
      {:ok, url} ->
        conn
        |> put_flash(:info, "Url shortned successfully.")
        |> redirect(to: ~p"/urls/#{url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    url = UrlShortner.get_url!(id)
    render(conn, :show, url: url)
  end
end
