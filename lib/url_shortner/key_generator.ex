defmodule UrlShortner.KeyGenerator do
  @moduledoc """
  Behaviour and reference implementation.
  Should generate a 7 char random string in the base 36 format.
  """

  @behaviour __MODULE__

  @callback generate() :: String.t()

  # TODO: make something more robust later on and use base36
  @impl __MODULE__
  def generate, do: :rand.bytes(4) |> Base.encode32(padding: false)
end
