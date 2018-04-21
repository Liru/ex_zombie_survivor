defmodule ZombieSurvivor.Survivor do
  alias __MODULE__

  @type t :: %__MODULE__{
          name: String.t(),
          wounds: non_neg_integer,
          equipment: [String.t()],
          experience: non_neg_integer
        }

  defstruct name: "", wounds: 0, equipment: [], experience: 0

  @spec new([{atom, any}]) :: Survivor.t()
  def new(opts \\ []), do: struct(__MODULE__, opts)

  @spec dead?(Survivor.t()) :: boolean
  def dead?(survivor), do: survivor.wounds >= 2

  @spec level(Survivor.t()) :: ZombieSurvivor.level()
  def level(survivor), do: ZombieSurvivor.level(survivor.experience)

  @spec max_actions(Survivor.t()) :: non_neg_integer
  def max_actions(_survivor) do
    3
  end

  @spec wound(Survivor.t(), non_neg_integer) :: Survivor.t()
  def wound(survivor, num \\ 1) do
    %{survivor | wounds: survivor.wounds + num}
    |> discard_equipment()
  end

  @spec kill_zombies(Survivor.t(), non_neg_integer) :: Survivor.t()
  def kill_zombies(survivor, count \\ 1) do
    %{survivor | experience: survivor.experience + count}
  end

  @spec max_equipment(Survivor.t()) :: non_neg_integer
  def max_equipment(%Survivor{} = survivor) do
    5 - survivor.wounds
  end

  @spec add_equipment(Survivor.t(), String.t() | [String.t()]) :: Survivor.t()
  def add_equipment(%Survivor{equipment: equipment} = survivor, new_items)
      when is_list(new_items) do
    %{survivor | equipment: Enum.concat(new_items, equipment)}
    |> discard_equipment()
  end

  def add_equipment(%Survivor{equipment: equipment} = survivor, new_item) do
    %{survivor | equipment: [new_item | equipment]}
    |> discard_equipment()
  end

  @spec discard_equipment(Survivor.t()) :: Survivor.t()
  def discard_equipment(%Survivor{equipment: equipment} = survivor) do
    max = max_equipment(survivor)
    %{survivor | equipment: Enum.take(equipment, max)}
  end
end
