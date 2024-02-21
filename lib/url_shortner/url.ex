defmodule UrlShortner.Url do
  use Ecto.Schema
  import Ecto.Changeset
  alias UrlShortner.Url.Original

  @type t :: %{
          short: String.t(),
          original_raw: String.t(),
          original: Original.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "urls" do
    field :short, :string
    field :original_raw, :string

    embeds_one :original, Original, primary_key: false, on_replace: :update do
      @type t :: %{
              scheme: String.t(),
              userinfo: String.t(),
              host: String.t(),
              port: String.t(),
              path: String.t(),
              query: %{String.t() => String.t()},
              fragment: String.t()
            }

      field :scheme, :string
      field :userinfo, :string
      field :host, :string
      field :port, :integer
      field :path, :string
      field :query, :map
      field :fragment, :string

      @spec from_url(String.t()) :: t()
      def from_url(url) do
        url
        |> URI.parse()
        |> Map.from_struct()
        |> Map.take(__MODULE__.__schema__(:fields))
      end
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(url, attrs) do
    # TODO: make something more robust later on and use base36
    short = :rand.bytes(4) |> Base.encode32(padding: false)

    changeset =
      url
      |> cast(attrs, [:original_raw])
      |> validate_required([:original_raw])

    changeset =
      if changeset.valid? do
        original = changeset |> get_field(:original_raw) |> Original.from_url()
        put_change(changeset, :original, original)
      else
        changeset
      end

    changeset
    |> put_change(:short, short)
  end
end
