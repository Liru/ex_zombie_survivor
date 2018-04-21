defmodule ZombieSurvivor.Survivor do
  alias __MODULE__

  @type t :: %__MODULE__{
          name: String.t(),
          wounds: non_neg_integer
        }

  defstruct name: "", wounds: 0

  @spec new([{atom, any}]) :: Survivor.t()
  def new(opts \\ []), do: struct(__MODULE__, opts)

  @spec dead?(Survivor.t()) :: boolean
  def dead?(survivor), do: survivor.wounds >= 2

  @spec max_actions(Survivor.t()) :: non_neg_integer
  def max_actions(_survivor) do
    3
  end
end
