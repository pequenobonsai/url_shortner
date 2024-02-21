defmodule UrlShortner.Repo.Migrations.CreateUrlVisits do
  use Ecto.Migration

  def change do
    create table(:url_visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :info, :map, null: false
      add :url_id, references(:urls, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:url_visits, [:url_id])
  end
end
