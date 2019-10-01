defmodule Proj2.Gossip do
    def initialize_gossip_actors(totalNodes) do
        middle_actor = trunc(totalNodes/2)
        Enum.map(1..totalNodes,
        fn x -> {:ok, actor} = 
        if x == middle_actor do
            Proj2.Client.start_link("rumour")
        else
            Proj2.Client.start_link("")
        end
        actor end)
    end
    #  -------------------------------   Start Gossip   -------------------------------  
    def gossip_algorithm(actors, neighbors, totalNodes) do
        for  {number, _}  <-  neighbors  do
        Proj2.Client.send_message(number)
        end

        actors = is_gossip_node_alive(actors)
        [{_, spread}] = :ets.lookup(:count, "spread")
        
        if ((spread != totalNodes) && (length(actors) > 1)) do
            neighbors = Enum.filter(neighbors, fn {number,_} -> Enum.member?(actors, number) end)
            gossip_algorithm(actors, neighbors, totalNodes)
        end
    end

    def is_gossip_node_alive(actors) do         #Checking the Termination condition of gossip algo for a node
        temp = Enum.map(actors, fn x -> if (Process.alive?(x) && Proj2.Client.get_count(x) < 10  && Proj2.Client.has_neighbors(x)) do x end end)
        List.delete(Enum.uniq(temp), nil)
    end

end