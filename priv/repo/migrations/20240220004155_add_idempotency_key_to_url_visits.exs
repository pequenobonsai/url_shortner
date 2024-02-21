defmodule UrlShortner.Repo.Migrations.AddIdempotencyKeyToUrlVisits do
  use Ecto.Migration

  def change do
    alter table(:url_visits) do
      add :idempotency_key, :string
    end

    execute("UPDATE url_visits SET idempotency_key = gen_random_uuid()")

    alter table(:url_visits) do
      modify :idempotency_key, :string, null: false, from: {:idempotency_key, :string}
    end

    create index(:url_visits, [:idempotency_key], unique: true)
  end
end
