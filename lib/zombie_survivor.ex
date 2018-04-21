defmodule ZombieSurvivor do
  @moduledoc """
  Documentation for ZombieSurvivor.
  """

  @type level :: :blue | :yellow | :orange | :red

  @spec level(non_neg_integer) :: level
  def level(experience) do
    case experience do
      x when x > 42 -> :red
      x when x > 18 -> :orange
      x when x > 6 -> :yellow
      _ -> :blue
    end
  end
end
