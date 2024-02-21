defmodule UrlShortner.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :original_raw, :string, null: false
      add :original, :map, null: false
      add :short, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:urls, [:short], unique: true)
  end
end
