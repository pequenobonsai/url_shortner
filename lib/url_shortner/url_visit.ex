defmodule UrlShortner.UrlVisit do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
          url_id: String.t(),
          info: map()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "url_visits" do
    # TODO: could hold info like user agent, remote ip, headers, cookies, etc
    field :info, :map
    field :idempotency_key, :string

    belongs_to :url, UrlShortner.Url

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(url_visit, attrs) do
    url_visit
    |> cast(attrs, [:info, :url_id, :idempotency_key])
    |> validate_required([:info, :idempotency_key])
    |> assoc_constraint(:url)
  end
end
