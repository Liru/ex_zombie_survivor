defmodule GameTest do
  use ExUnit.Case
  alias ZombieSurvivor.{Game, Survivor}

  doctest Game

  @new_survivor Survivor.new(name: "Zombait")
  @dead_survivor Survivor.new(name: "Deadman", wounds: 2)

  setup do
    game = start_supervised!(Game)
    %{game: game}
  end

  describe "new/0 starts a game" do
    test "that has 0 survivors", %{game: game} do
      assert Map.size(Game.survivors(game)) == 0
    end

    test "that's at level blue", %{game: game} do
      assert Game.level(game) == :blue
    end
  end

  describe "add_survivor/1" do
    test "adds a survivor to a game", %{game: game} do
      Game.add_survivor(game, @new_survivor)

      assert Map.size(Game.survivors(game)) == 1

      Game.add_survivor(game, %{@new_survivor | name: "Larry"})

      assert Map.size(Game.survivors(game)) == 2
    end

    test "ensures that two survivors with the same name can't exist", %{game: game} do
      game
      |> Game.add_survivor(@new_survivor)
      |> Game.add_survivor(@new_survivor)

      assert Map.size(Game.survivors(game)) == 1
    end
  end

  describe "ended?/1" do
    test "returns true if all its survivors are dead", %{game: game} do
      # TODO: Property test, add many dead survivors
      game
      |> Game.add_survivor(@dead_survivor)

      assert Game.ended?(game)

      game
      |> Game.add_survivor(%{@dead_survivor | name: "Zambee"})

      assert Game.ended?(game)
    end

    test "returns false if at least one survivor is alive", %{game: game} do
      game
      |> Game.add_survivor(@new_survivor)
      |> Game.add_survivor(@dead_survivor)

      refute Game.ended?(game)
    end

    test "returns false if no survivors joined", %{game: game} do
      refute Game.ended?(game)
    end
  end

  describe "level/1" do
    test "returns the level of the highest levelled survivor", %{game: game} do
      Game.add_survivor(game, @new_survivor)

      assert Game.level(game) == :blue

      Game.add_survivor(game, Survivor.new(name: "Eric", experience: 10))

      assert Game.level(game) == :yellow

      Game.add_survivor(game, Survivor.new(name: "Jack", experience: 20))

      assert Game.level(game) == :orange
      Game.add_survivor(game, Survivor.new(name: "Liru", experience: 1_000_000))

      assert Game.level(game) == :red
    end

    test "returns the level of the highest levelled living survivor", %{game: game} do
      Game.add_survivor(game, @new_survivor)

      assert Game.level(game) == :blue

      Game.add_survivor(game, Survivor.new(name: "Eric", experience: 10))

      assert Game.level(game) == :yellow

      Game.add_survivor(game, %{@dead_survivor | name: "Jack", experience: 20})

      assert Game.level(game) == :yellow

      Game.add_survivor(game, %{@dead_survivor | name: "Fake Liru", experience: 1_000_000})

      assert Game.level(game) == :yellow
    end
  end
end
