defmodule UrlShortner do
  import Ecto.Query, warn: false
  alias UrlShortner.Repo
  alias UrlShortner.Url

  @spec get_url!(String.t()) :: Url.t()
  def get_url!(id), do: Repo.get!(Url, id)

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
end
