defmodule ZombieSurvivor.Game do
  alias ZombieSurvivor.{Game.State, Survivor}

  use GenServer

  def new, do: start_link()

  def add_history(pid, tuple), do: GenServer.call(pid, {:add_history, tuple})
  def add_survivor(pid, survivor), do: GenServer.call(pid, {:add_survivor, survivor})
  def ended?(pid), do: GenServer.call(pid, :ended?)

  def give_equipment(pid, survivor, item),
    do: GenServer.call(pid, {:give_equipment, survivor, item})

  def history(pid), do: GenServer.call(pid, :history)

  def kill_zombies(pid, survivor, count),
    do: GenServer.call(pid, {:kill_zombies, survivor, count})

  def level(pid), do: GenServer.call(pid, :level)
  def survivors(pid), do: GenServer.call(pid, :survivors)
  def wound(pid, survivor), do: GenServer.call(pid, {:wound, survivor})

  ## Server callbacks

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl GenServer
  def init(:ok) do
    s = State.new()
    {:ok, %{s | history: [{:start, DateTime.utc_now()} | s.history]}}
  end

  @impl GenServer
  def handle_call({:add_history, tuple}, _from, state) do
    s = %{state | history: [tuple | state.history]}
    {:reply, s, s}
  end

  def handle_call({:add_survivor, survivor}, _from, state) do
    s = State.add_survivor(state, survivor)
    {:reply, s, s}
  end

  def handle_call(:ended?, _from, state) do
    {:reply, State.ended?(state), state}
  end

  def handle_call({:give_equipment, survivor, item}, _from, state) do
    s = State.give_equipment(state, survivor, item)
    {:reply, s, s}
  end

  def handle_call(:history, _from, state) do
    {:reply, state.history, state}
  end

  def handle_call({:kill_zombies, survivor, count}, _from, state) do
    s = State.kill_zombies(state, survivor, count)
    {:reply, s, s}
  end

  def handle_call(:level, _from, state) do
    {:reply, State.level(state), state}
  end

  def handle_call(:survivors, _from, state) do
    {:reply, state.survivors, state}
  end

  def handle_call({:wound, survivor}, _from, state) do
    s = State.wound_survivor(state, survivor)
    {:reply, s, s}
  end
end
