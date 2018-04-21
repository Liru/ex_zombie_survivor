defmodule SurvivorTest do
  use ExUnit.Case
  alias ZombieSurvivor.Survivor

  import Survivor

  @items ["Baseball bat", "Frying pan", "Katana", "Pistol", "Bottled Water", "Molotov"]

  describe "new" do
    test "gives a survivor with a name" do
      assert %Survivor{name: _} = Survivor.new()
    end

    test "gives a survivor with 0 wounds" do
      assert %Survivor{wounds: 0} = Survivor.new()
    end
  end

  describe "dead?/1" do
    # TODO: Add property test for this
    test "returns true if a survivor has 2 or more wounds" do
      s = Survivor.new(wounds: 2)
      assert Survivor.dead?(s)

      s = Survivor.new(wounds: 3)
      assert Survivor.dead?(s)
    end

    test "returns false if a survivor has less than 2 wounds" do
      s = Survivor.new()
      refute Survivor.dead?(s)

      s = Survivor.new()
      refute Survivor.dead?(s)
    end
  end

  describe "max_actions/1" do
    test "returns 3 for a new survivor" do
      s = Survivor.new()
      assert Survivor.max_actions(s) == 3
    end
  end

  describe "max_equipment/1" do
    test "returns 5 for a new survivor" do
      assert 5 == max_equipment(Survivor.new())
    end

    test "returns fewer items with more wounds" do
      s =
        Survivor.new()
        |> Survivor.wound()

      assert max_equipment(s) == 4
    end
  end

  describe "wound/1" do
    # TODO: Property testing with increments
    test "adds wounds to survivors (duh)" do
      s =
        Survivor.new()
        |> wound()

      assert %{wounds: 1} = s
    end

    test "drops survivor equipment if they are carrying too much" do
      # TODO: Property testing
      # kinda funky if max_equipment rules change, will fix later
      s =
        Survivor.new()
        |> add_equipment(@items)

      max = max_equipment(s)
      assert max == length(s.equipment)

      s =
        s
        |> wound

      assert max - 1 == length(s.equipment)
    end

    test "doesn't drop survivor equipment if they aren't carrying too much" do
      s =
        Survivor.new()
        |> add_equipment("Corncob")

      assert 1 == length(s.equipment)

      s =
        s
        |> wound

      assert 1 == length(s.equipment)
    end
  end
end
