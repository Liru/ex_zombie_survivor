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
      Game.add_survivor(game, @new_survivor)
      Game.add_survivor(game, @new_survivor)

      assert Map.size(Game.survivors(game)) == 1
    end
  end

  describe "ended?/1" do
    test "returns true if all its survivors are dead", %{game: game} do
      # TODO: Property test, add many dead survivors
      Game.add_survivor(game, @dead_survivor)

      assert Game.ended?(game)

      Game.add_survivor(game, %{@dead_survivor | name: "Zambee"})

      assert Game.ended?(game)
    end

    test "returns false if at least one survivor is alive", %{game: game} do
      Game.add_survivor(game, @new_survivor)
      Game.add_survivor(game, @dead_survivor)

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

  describe "game history" do
    test "begins by recording the time the game began", %{game: game} do
      assert {:start, _} = hd(Game.history(game))
    end

    test "notes that a survivor has been added", %{game: game} do
      s = @new_survivor
      Game.add_survivor(game, s)
      assert {:new_survivor, s.name} in Game.history(game)

      s2 = %{@new_survivor | name: "Bob"}
      Game.add_survivor(game, s2)
      assert {:new_survivor, s2.name} in Game.history(game)
    end

    test "notes that a survivor acquires a piece of equipment", %{game: game} do
      # TODO: Property test: check item names
      s = @new_survivor

      Game.add_survivor(game, s)
      Game.give_equipment(game, s, "Cheese")

      log = Game.history(game)

      # IO.inspect history
      assert {:new_equipment, {s.name, "Cheese"}} in log
    end

    test "notes that a survivor is wounded", %{game: game} do
      s = @new_survivor

      Game.add_survivor(game, s)
      Game.wound(game, s)
      log = Game.history(game)

      assert {:wounded, s.name} in log
    end

    test "notes that a survivor dies", %{game: game} do
      Game.add_survivor(game, @new_survivor)
      Game.add_survivor(game, %{@new_survivor | name: "Bob"})
      Game.wound(game, @new_survivor)
      Game.wound(game, @new_survivor)
      log = Game.history(game)

      assert {:death, @new_survivor.name} in log
    end

    test "notes that a survivor levels up", %{game: game} do
      Game.add_survivor(game, @new_survivor)
      Game.kill_zombies(game, @new_survivor, 10)

      log = Game.history(game)

      assert {:levelup, @new_survivor.name} in log
    end

    test "notes that the game level changes", %{game: game} do
      Game.add_survivor(game, @new_survivor)
      Game.add_survivor(game, %{@new_survivor | name: "Bob"})
      Game.kill_zombies(game, @new_survivor, 10)

      log = Game.history(game)

      assert {:game_level, :yellow} in log

      Game.wound(game, @new_survivor)
      Game.wound(game, @new_survivor)
      log = Game.history(game)

      assert {:game_level, :blue} in log
    end

    test "notes that the game ends", %{game: game} do
      Game.add_survivor(game, @new_survivor)
      Game.wound(game, @new_survivor)
      Game.wound(game, @new_survivor)
      log = Game.history(game)

      assert {:end, _} = hd(log)
    end
  end
end
