defmodule UrlShortner do
  import Ecto.Query, warn: false
  alias UrlShortner.Repo
  alias UrlShortner.Url
  alias UrlShortner.UrlVisit

  @spec get_url!(String.t()) :: Url.t()
  def get_url!(id), do: Repo.get!(Url, id)

  @spec get_url_by(%{by: String.t()}) :: Url.t() | nil
  def get_url_by(by), do: Repo.get_by(Url, by)

  @spec create_url(%{}) :: {:ok, Url.t()} | {:error, Ecto.Changeset.t()}
  def create_url(attrs \\ %{}) do
    %Url{}
    |> Url.changeset(attrs)
    |> Repo.insert()
  end

  @spec change_url(%{}) :: Ecto.Changeset.t()
  def change_url(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end

  @spec create_url_visit_for(Url.t()) :: {:ok, UrlVisit.t()} | {:error, Ecto.Changeset.t()}
  def create_url_visit_for(url) do
    %UrlVisit{}
    |> UrlVisit.changeset(%{url_id: url.id, info: %{}})
    |> Repo.insert()
  end

  @spec urls_with_visit :: [Url.t()]
  def urls_with_visit do
    query =
      from u in Url,
        left_join: uv in UrlVisit,
        on: u.id == uv.url_id,
        group_by: u.id,
        order_by: [desc: count(uv.id)],
        select: %{u | visits: count(uv.id)}

    Repo.all(query)
  end
end
