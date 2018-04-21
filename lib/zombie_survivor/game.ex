defmodule ZombieSurvivor.Game do
  alias ZombieSurvivor.{Game, Survivor}

  @type t :: %__MODULE__{survivors: %{String.t() => Survivor.t()}}

  defstruct survivors: %{}

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
end
