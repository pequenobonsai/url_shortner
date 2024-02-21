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

      @spec valid?(t()) :: boolean()
      def valid?(url) do
        url
        |> Map.take([:scheme, :host, :port])
        |> Map.values()
        |> Enum.all?(&(&1 != nil && &1 != ""))
      end
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:original_raw])
    |> validate_required([:original_raw])
    |> parse_original_raw_into_original()
    |> put_change(:short, key_generator().generate())
  end

  defp parse_original_raw_into_original(changeset = %{valid?: false}), do: changeset

  defp parse_original_raw_into_original(changeset = %{valid?: true}) do
    original = changeset |> get_field(:original_raw) |> Original.from_url()

    if Original.valid?(original) do
      put_change(changeset, :original, original)
    else
      add_error(changeset, :original_raw, "Invalid URL")
    end
  end

  defp key_generator do
    Application.get_env(:url_shortner, :key_generator)
  end
end
