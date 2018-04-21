defmodule ZombieSurvivor.Game.State do
  alias __MODULE__
  alias ZombieSurvivor.Survivor

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
          | :game_level
          | :end

  defstruct survivors: %{}, history: []

  @spec new() :: State.t()
  def new(), do: %State{}

  @spec add_survivor(State.t(), Survivor.t()) :: State.t()
  def add_survivor(game, survivor) do
    name = survivor.name

    if Map.has_key?(game, name) do
      game
    else
      %{game | survivors: Map.put(game.survivors, name, survivor)}
      |> add_history({:new_survivor, survivor.name})
    end
  end

  @spec ended?(State.t()) :: boolean
  def ended?(%State{survivors: survivors}) when map_size(survivors) == 0, do: false

  def ended?(game) do
    Enum.all?(game.survivors, fn {_, survivor} ->
      Survivor.dead?(survivor)
    end)
  end

  @spec give_equipment(State.t(), Survivor.t(), String.t()) :: State.t()
  def give_equipment(game, survivor, item) do
    name = survivor.name

    new_survivors = Map.update!(game.survivors, name, &Survivor.add_equipment(&1, item))

    %{game | survivors: new_survivors}
    |> add_history({:new_equipment, {name, item}})
  end

  @spec level(State.t()) :: ZombieSurvivor.level()
  def level(game) do
    game.survivors
    |> Enum.reject(fn {_, s} -> Survivor.dead?(s) end)
    |> Enum.reduce(0, fn {_, s}, acc -> max(s.experience, acc) end)
    |> ZombieSurvivor.level()
  end

  @spec kill_zombies(State.t(), Survivor.t(), non_neg_integer) :: State.t()
  def kill_zombies(game, survivor, count) do
    name = survivor.name

    old_game_level = level(game)

    survivors = game.survivors

    old_survivor_level = Survivor.level(survivors[name])
    new_survivors = Map.update!(survivors, name, &Survivor.kill_zombies(&1, count))
    new_survivor_level = Survivor.level(new_survivors[name])

    g = %{game | survivors: new_survivors}
    new_game_level = level(g)

    g
    |> add_history({:levelup, name}, old_survivor_level != new_survivor_level)
    |> add_history({:game_level, new_game_level}, old_game_level != new_game_level)
  end

  @spec wound_survivor(State.t(), Survivor.t()) :: State.t()
  def wound_survivor(game, survivor) do
    name = survivor.name

    old_game_level = level(game)

    survivors = game.survivors
    new_survivors = Map.update!(survivors, name, &Survivor.wound(&1))

    game = %{game | survivors: new_survivors}

    new_game_level = level(game)

    game
    |> add_history({:wounded, name}, !Survivor.dead?(new_survivors[name]))
    |> add_history({:death, name}, Survivor.dead?(new_survivors[name]))
    |> add_history({:game_level, new_game_level}, old_game_level != new_game_level)
    |> add_history({:end, DateTime.utc_now()}, ended?(game))
  end

  ## Private

  @spec add_history(State.t(), tuple, boolean) :: State.t()
  defp add_history(state, entry, comp \\ true) do
    if comp do
      %{state | history: [entry | state.history]}
    else
      state
    end
  end
end
