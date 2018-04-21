defmodule ZombieSurvivor.Game do
  alias ZombieSurvivor.{Game, Survivor}

  defmodule State do
    alias __MODULE__, as: Game

    @type t :: %__MODULE__{
            survivors: %{String.t() => Survivor.t()},
            history: [String.t()]
          }
    @type history_type ::
            :start
            | :new_survivor
            | :new_equipment
            | :wounded
            | :death
            | :levelup
            | :game_levelup
            | :end
    @type history :: {history_type, any}

    defstruct survivors: %{}, history: []

    @spec new() :: Game.t()
    def new(), do: %Game{}

    @spec add_survivor(Game.t(), Survivor.t()) :: Game.t()
    def add_survivor(game, survivor) do
      name = survivor.name

      if Map.has_key?(game, name) do
        game
      else
        %{game | survivors: Map.put(game.survivors, name, survivor)}
      end
    end

    @spec ended?(Game.t()) :: boolean
    def ended?(%Game{survivors: survivors}) when map_size(survivors) == 0, do: false

    def ended?(game) do
      Enum.all?(game.survivors, fn {_, survivor} ->
        Survivor.dead?(survivor)
      end)
    end

    @spec level(Game.t()) :: ZombieSurvivor.level()
    def level(game) do
      game.survivors
      |> Enum.reject(fn {_, s} -> Survivor.dead?(s) end)
      |> Enum.reduce(0, fn {_, s}, acc -> max(s.experience, acc) end)
      |> ZombieSurvivor.level()
    end
  end

  use GenServer

  def new, do: start_link()

  def add_survivor(pid, survivor), do: GenServer.cast(pid, {:add_survivor, survivor})
  def ended?(pid), do: GenServer.call(pid, :ended?)
  def history(pid), do: GenServer.call(pid, :history)
  def level(pid), do: GenServer.call(pid, :level)
  def survivors(pid), do: GenServer.call(pid, :survivors)

  ## Server callbacks

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl GenServer
  def init(:ok) do
    {:ok, State.new()}
  end

  @impl GenServer
  def handle_call(:ended?, _from, state) do
    {:reply, State.ended?(state), state}
  end

  def handle_call(:history, _from, state) do
    {:reply, state.history, state}
  end

  def handle_call(:level, _from, state) do
    {:reply, State.level(state), state}
  end

  def handle_call(:survivors, _from, state) do
    {:reply, state.survivors, state}
  end

  @impl GenServer
  def handle_cast({:add_survivor, survivor}, state) do
    {:noreply, State.add_survivor(state, survivor)}
  end
end
