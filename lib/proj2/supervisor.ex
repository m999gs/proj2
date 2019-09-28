defmodule Proj2.Supervisor do
    use Supervisor
    
    def start_link(init_arg) do
        Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    def init(init_arg) do
        {_pid, totalNodes, topology, algorithm} = init_arg
        if totalNodes>1 do
            case algorithm do
                "gossip" ->
                    IO.puts("Initializing gossip algorithm")
                    actors=initialize_gossip_actors(totalNodes);
                    initialize_algorithm(actors, topology, totalNodes, algorithm)

                "push-sum" ->
                    IO.puts("Initializing push sum algorithm")
                    actors=initialize_actors_push_sum(totalNodes);
                    initialize_algorithm(actors, topology, totalNodes, algorithm)
                    
                _ ->
                    IO.puts "you have entered the wrong algorithm name"
                    IO.puts "please use gossip or push-sum as an algorithm name in 3rd argument"
            end

        end
    # {:ok, init_arg}   #Bad value 
    children = [
      # Starts a worker by calling: Proj2.Worker.start_link(arg)
      # {Proj2.Worker, arg}
    ]

    # opts = [strategy: :one_for_one, name: Proj2.Supervisor]
    # Supervisor.start_link(children, opts)
    Supervisor.init(children, strategy: :one_for_one)
    end
    #  --------------------   Prepare Actors to start Rumour for gossip protocol   --------------------
    def initialize_gossip_actors(totalNodes) do
        middle_actor = trunc(totalNodes/2)
        Enum.map(1..totalNodes,
        fn x -> {:ok, actor} = 
        if x == middle_actor do
            Proj2.Client.start_link("Rumour have started")
        else
            Proj2.Client.start_link("")
        end
        actor end)
    end

    #  --------------------   Prepare Actors to start Rumour for Push-sum   --------------------
    def initialize_actors_push_sum(totalNodes) do
        middle_actor = trunc(totalNodes/2)
        Enum.map(1..totalNodes,
        fn x -> {:ok, actor} =
            if x == middle_actor do
                x = Integer.to_string(x)
                {x, _} = Float.parse(x)
                Proj2.Client.start_link([x] ++ ["Rumour have started"])
            else
                x = Integer.to_string(x)
                {x, _} = Float.parse(x)
                Proj2.Client.start_link([x] ++ [""])
            end
        actor end)
    end

    def initialize_algorithm(actors, topology, totalNodes, algorithm) do
        :ets.new(:count, [:set, :public, :named_table])
        :ets.insert(:count, {"spread", 0})
    
        # Determine Neighbor nodes as per requested topology
        neighbors =
        case topology do
            "full" ->
                  IO.puts "Implementing full topology"
                  _neighbors = Proj2.Topologies.determine_nodes_full(actors)
            "line" ->
                  IO.puts "Implementing line topology"
                  _neighbors = Proj2.Topologies.determine_nodes_line(actors)
            "rand2D" ->
                  IO.puts "Implementing random 2D topology"
                  _neighbors = Proj2.Topologies.determine_nodes_rand2D(actors)
            "3Dtorus" ->
                  IO.puts("Implementing 3D torus grid topology")
                  _neighbors = Proj2.Topologies.determine_nodes_3D(actors)
            "honeycomb" ->
                  IO.puts("Implementing honeycomb topology")
                  _neighbors = Proj2.Topologies.determine_nodes_honeycomb(actors,topology)
            "randhoneycomb" ->
                  IO.puts("Implementing honeycomb topology with random neighbors")
                  _neighbors = Proj2.Topologies.determine_nodes_honeycomb(actors,topology)
             _ ->
                  IO.puts "Please use one of full | line | rand2D | 3Dtorus | honeycomb | randhoneycomb as topology"
                  System.halt(0)
          end
            
          for  {number, y}  <-  neighbors  do
            Proj2.Client.set_neighbors(number, y)
          end

        start_time = System.monotonic_time(:millisecond)

        case algorithm do
        "gossip" ->
            gossip_algorithm(actors, neighbors, totalNodes)
        "push-sum" ->
            push_sum_algorithm(actors, neighbors, totalNodes)
        end

        IO.puts "Convergence Time: " <> to_string(System.monotonic_time(:millisecond) - start_time) <> " milliseconds"
        System.halt(0)
    end
    #  -------------------------------   Start Gossip   -------------------------------  
    def gossip_algorithm(actors, neighbors, totalNodes) do
        for  {number, _}  <-  neighbors  do
        Proj2.Client.send_message(number)
        end

        actors = verify_actors_alive(actors)
        [{_, spread}] = :ets.lookup(:count, "spread")

        if ((spread != totalNodes) && (length(actors) > 1)) do
        neighbors = Enum.filter(neighbors, fn {number,_} -> Enum.member?(actors, number) end)
        gossip_algorithm(actors, neighbors, totalNodes)
        end
    end

    def verify_actors_alive(actors) do
        temp = Enum.map(actors, fn x -> if (Process.alive?(x) && Proj2.Client.get_count(x) < 10  && Proj2.Client.has_neighbors(x)) do x end end)
        List.delete(Enum.uniq(temp), nil)
    end

    #  ---------------------   Start Push Sum   ---------------------
    def push_sum_algorithm(actors, neighbors, totalNodes) do
        #for  {number, y}  <-  neighbors  do
        for  {number, _}  <-  neighbors  do
        Proj2.Client.send_message_push_sum(number)
        end

        actors = verify_actors_alive_ps(actors)
        [{_, spread}] = :ets.lookup(:count, "spread")
        
        if ((spread != totalNodes) && (length(actors) > 1)) do
        neighbors = Enum.filter(neighbors, fn ({number,_}) -> Enum.member?(actors, number) end)
        push_sum_algorithm(actors, neighbors, totalNodes)
        end
    end

    def verify_actors_alive_ps(actors) do
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