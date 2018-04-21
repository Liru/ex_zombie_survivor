defmodule SurvivorTest do
  use ExUnit.Case
  alias ZombieSurvivor.Survivor

  import Survivor

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
end
