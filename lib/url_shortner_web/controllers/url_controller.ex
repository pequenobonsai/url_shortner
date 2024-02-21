defmodule UrlShortnerWeb.UrlController do
  use UrlShortnerWeb, :controller
  alias UrlShortner.Url
  alias UrlShortner.EventBroker
  alias UrlShortner.EventBroker.Events.Visit

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

  def route(conn, %{"short" => short}) do
    url = UrlShortner.get_url_by(short: short)

    if url do
      EventBroker.publish(%Visit{url: url, idempotency_key: Ecto.UUID.generate()})
      redirect(conn, external: url.original_raw)
    else
      conn
      |> put_flash(:error, "URL not found")
      |> redirect(to: ~p"/urls/new")
    end
  end
end
