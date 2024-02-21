defmodule UrlShortner.KeyGenerator do
  @moduledoc """
  Behaviour and reference implementation.
  Should generate a 7 char random string in the base 36 format.
  """

  use GenServer, restart: :permanent

  @behaviour __MODULE__

  @callback generate() :: String.t()

  @target 300
  @threshold 300 / 2
  @refill_every :timer.seconds(10)

  @impl __MODULE__
  def generate, do: GenServer.call(__MODULE__, :consume)

  def state, do: GenServer.call(__MODULE__, :state)

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl GenServer
  def init(_state) do
    Process.send_after(self(), :refill, @refill_every)
    {:ok, %{count: @target, keys: generate_keys()}}
  end

  @impl GenServer
  def handle_call(:consume, _from, state) do
    [key | keys] = state.keys
    count = state.count - 1

    if count <= @threshold, do: send(self(), :refill)

    {:reply, key, %{state | keys: keys, count: count}}
  end

  @impl GenServer
  def handle_call(:state, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_info(:refill, state) do
    keys = Enum.take(generate_keys(), max(@target - state.count, 0))

    {:noreply,
     %{state | keys: Enum.concat(state.keys, keys), count: state.count + Enum.count(keys)}}
  end

  # generate 300 4 bytes encoded in base 32 which gives us 7 chars
  # then filter everything that is not on the database already
  #
  # this does not eliminate collisions since on a concurrent scenario
  # (many pods, os processes etc) scenario we could have two values
  # that are the same and would be valid for both instances if checked
  # at the same time by the database
  #
  # but we are optimzing here for reducing the likelihood
  defp generate_keys do
    shorts =
      for <<chunk::size(4)-binary <- :rand.bytes(4 * @target)>>,
        do: %{short: Base.encode32(chunk, padding: false)}

    UrlShortner.filter_non_existent(shorts)
  end
end
