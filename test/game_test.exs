defmodule GameTest do
  use ExUnit.Case
  alias ZombieSurvivor.{Game, Survivor}

  doctest Game

  @new_survivor Survivor.new(name: "Zombait")
  @dead_survivor Survivor.new(name: "Deadman", wounds: 2)

  describe "new/0 starts a game" do
    test "that has 0 survivors" do
      assert Map.size(Game.new().survivors) == 0
    end

    test "that's at level blue" do
      assert Game.level(Game.new()) == :blue
    end
  end

  describe "add_survivor/1" do
    test "adds a survivor to a game" do
      g =
        Game.new()
        |> Game.add_survivor(@new_survivor)

      assert Map.size(g.survivors) == 1

      g =
        g
        |> Game.add_survivor(%{@new_survivor | name: "Larry"})

      assert Map.size(g.survivors) == 2
    end

    test "ensures that two survivors with the same name can't exist" do
      g =
        Game.new()
        |> Game.add_survivor(@new_survivor)
        |> Game.add_survivor(@new_survivor)

      assert Map.size(g.survivors) == 1
    end
  end

  describe "ended?/1" do
    test "returns true if all its survivors are dead" do
      # TODO: Property test, add many dead survivors
      g =
        Game.new()
        |> Game.add_survivor(@dead_survivor)

      assert Game.ended?(g)

      g =
        g
        |> Game.add_survivor(%{@dead_survivor | name: "Zambee"})

      assert Game.ended?(g)
    end

    test "returns false if at least one survivor is alive" do
      g =
        Game.new()
        |> Game.add_survivor(@new_survivor)
        |> Game.add_survivor(@dead_survivor)

      refute Game.ended?(g)
    end

    test "returns false if no survivors joined" do
      g = Game.new()

      refute Game.ended?(g)
    end
  end

  describe "level/1" do
    test "returns the level of the highest levelled survivor" do
      g =
        Game.new()
        |> Game.add_survivor(@new_survivor)

      assert Game.level(g) == :blue

      g =
        g
        |> Game.add_survivor(Survivor.new(name: "Eric", experience: 10))

      assert Game.level(g) == :yellow

      g =
        g
        |> Game.add_survivor(Survivor.new(name: "Jack", experience: 20))

      assert Game.level(g) == :orange

      g =
        g
        |> Game.add_survivor(Survivor.new(name: "Liru", experience: 1_000_000))

      assert Game.level(g) == :red
    end

    test "returns the level of the highest levelled living survivor" do
      g =
        Game.new()
        |> Game.add_survivor(@new_survivor)

      assert Game.level(g) == :blue

      g =
        g
        |> Game.add_survivor(Survivor.new(name: "Eric", experience: 10))

      assert Game.level(g) == :yellow

      g =
        g
        |> Game.add_survivor(Survivor.new(name: "Jack", experience: 20, wounds: 2))

      assert Game.level(g) == :yellow

      g =
        g
        |> Game.add_survivor(Survivor.new(name: "Liru", experience: 1_000_000, wounds: 2))

      assert Game.level(g) == :yellow
    end
  end
end
