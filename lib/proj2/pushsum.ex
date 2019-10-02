defmodule Proj2.PushSum do

    def initialize_actors_push_sum(totalNodes) do
        middle_actor = trunc(totalNodes/2)
        Enum.map(1..totalNodes,
        fn x -> {:ok, actor} =
            if x == middle_actor do
                x = Integer.to_string(x)
                {x, _} = Float.parse(x)
                Proj2.Client.start_link([x] ++ ["rumor"])
            else
                x = Integer.to_string(x)
                {x, _} = Float.parse(x)
                Proj2.Client.start_link([x] ++ [""])
            end
        actor end)
    end
    
    def push_sum_algorithm(actors, neighbors, totalNodes) do
        for  {node, _}  <-  neighbors  do
        Proj2.Client.message_send_push_sum(node)
        end

        actors = is_pushsum_node_alive(actors)
        [{_, spread}] = :ets.lookup(:count, "spread")
        
        if ((spread != totalNodes) && (length(actors) > 1)) do
        neighbors = Enum.filter(neighbors, fn ({node,_}) -> Enum.member?(actors, node) end)
        push_sum_algorithm(actors, neighbors, totalNodes)
        end
    end

    def is_pushsum_node_alive(actors) do        #Checking the Termination condition of Push-sum algo for a node
        temp = Enum.map(actors,
            fn x ->
            diff = Proj2.Client.get_diff(x)
            if(Process.alive?(x) && Proj2.Client.has_neighbors(x) && (abs(List.first(diff)) > :math.pow(10, -10)
                    || abs(List.last(diff)) > :math.pow(10, -10))) do
                x
            end
            end)
        List.delete(Enum.uniq(temp), nil)
    end
    
end