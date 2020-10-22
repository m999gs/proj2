defmodule Proj2.Client do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(arg) do
    GenServer.start_link(Proj2.Server, arg)
  end

  def message_send(server) do
    GenServer.cast(server, {:send_gossip_message})
  end

  def message_send_push_sum(server) do
    GenServer.cast(server, {:send_pushsum_message})
  end

  def set_neighbors(server, neighbors) do
    GenServer.cast(server, {:set_neighbors, neighbors})
  end

  def get_neighbors(server) do
    GenServer.call(server, {:get_neighbors})
  end

  def has_neighbors(server) do
    {:ok, neighbors} = GenServer.call(server, {:get_neighbors})
    length(neighbors) > 0
  end

  def get_count(server) do
    {:ok, count} = GenServer.call(server, {:get_count, "count"})
    count
  end

  def get_rumor(server) do
    {:ok, rumor} = GenServer.call(server, {:get_rumor, "rumor"})
    rumor
  end

  def get_diff(server) do
    GenServer.call(server, {:get_diff})
  end
end
