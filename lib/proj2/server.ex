defmodule Proj2.Server do
  use GenServer

  def init(arg) do
    # runs on push-sum as per List trigger
    if is_list(arg) do
      {:ok,
       %{
         "s" => List.first(arg),
         "rumor" => List.last(arg),
         "w" => 1,
         "s_old_2" => 1,
         "w_old_2" => 1,
         "diff1" => 1,
         "diff2" => 1,
         "neighbors" => []
       }}

      # runs on gossip
    else
      {:ok, %{"rumor" => arg, "count" => 0, "neighbors" => []}}
    end
  end

  def handle_cast({:receive_gossip_message, rumor, sender}, state) do
    {:ok, count} = Map.fetch(state, "count")
    state = Map.put(state, "count", count + 1)

    cond do
      count > 10 ->
        _ = GenServer.cast(sender, {:remove_neighbor, self()})
        {:noreply, state}

      true ->
        {:ok, existing_rumor} = Map.fetch(state, "rumor")

        cond do
          existing_rumor != "" ->
            {:noreply, state}

          true ->
            [{_, spread}] = :ets.lookup(:count, "spread")
            :ets.insert(:count, {"spread", spread + 1})
            {:noreply, Map.put(state, "rumor", rumor)}
        end
    end
  end

  def handle_cast({:receive_push_sum_message, sender, s, w, rumor}, state) do
    {:ok, s_old} = Map.fetch(state, "s")
    {:ok, w_old} = Map.fetch(state, "w")
    {:ok, s_old_2} = Map.fetch(state, "s_old_2")
    {:ok, w_old_2} = Map.fetch(state, "w_old_2")
    {:ok, existing_rumor} = Map.fetch(state, "rumor")

    s_new = s_old + s
    w_new = w_old + w

    cond do
      abs(s_new / w_new - s_old / w_old) < :math.pow(10, -10) &&
          abs(s_old / w_old - s_old_2 / w_old_2) < :math.pow(10, -10) ->
        GenServer.cast(sender, {:remove_neighbor, self()})

      true ->
        cond do
          existing_rumor == "" ->
            Map.put(state, "rumor", rumor)
            [{_, spread}] = :ets.lookup(:count, "spread")
            :ets.insert(:count, {"spread", spread + 1})
        end

        Map.put(state, "s", s_new)
        Map.put(state, "w", w_new)
        Map.put(state, "s_old_2", s_old)
        Map.put(state, "w_old_2", w_old)
        _ = Map.put(state, "diff1", s_new / w_new - s_old / w_old)
        _ = Map.put(state, "diff2", s_old / w_old - s_old_2 / w_old_2)
        {:noreply, state}
    end
  end

  def handle_cast({:send_gossip_message}, state) do
    {:ok, rumor} = Map.fetch(state, "rumor")
    {:ok, neighbors} = Map.fetch(state, "neighbors")

    if rumor != "" && length(neighbors) > 0 do
      _ = GenServer.cast(Enum.random(neighbors), {:receive_gossip_message, rumor, self()})
    end

    {:noreply, state}
  end

  def handle_cast({:send_pushsum_message}, state) do
    {:ok, s} = Map.fetch(state, "s")
    {:ok, w} = Map.fetch(state, "w")
    {:ok, rumor} = Map.fetch(state, "rumor")
    {:ok, neighbors} = Map.fetch(state, "neighbors")

    if rumor != "" && length(neighbors) > 0 do
      s = s / 2
      w = w / 2
      state = Map.put(state, "s", s)
      Map.put(state, "w", w)
      GenServer.cast(Enum.random(neighbors), {:receive_push_sum_message, self(), s, w, rumor})
    end

    {:noreply, state}
  end

  def handle_cast({:remove_neighbor, neighbor}, state) do
    {:ok, neighbors} = Map.fetch(state, "neighbors")
    {:noreply, Map.put(state, "neighbors", List.delete(neighbors, neighbor))}
  end

  def handle_cast({:set_neighbors, neighbors}, state) do
    {:noreply, Map.put(state, "neighbors", neighbors)}
  end

  def handle_call({:get_count, count}, _from, state) do
    {:reply, Map.fetch(state, count), state}
  end

  def handle_call({:get_rumor, rumor}, _from, state) do
    {:reply, Map.fetch(state, rumor), state}
  end

  def handle_call({:get_neighbors}, _from, state) do
    {:reply, Map.fetch(state, "neighbors"), state}
  end

  def handle_call({:get_diff}, _from, state) do
    {:ok, diff1} = Map.fetch(state, "diff1")
    {:ok, diff2} = Map.fetch(state, "diff2")
    {:reply, [diff1] ++ [diff2], state}
  end
end
