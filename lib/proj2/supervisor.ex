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
                    actors=Proj2.Gossip.initialize_gossip_actors(totalNodes);
                    initialize_algorithm(actors, topology, totalNodes, algorithm)

                "push-sum" ->
                    IO.puts("Initializing push-sum algorithm")
                    actors=Proj2.PushSum.initialize_actors_push_sum(totalNodes);
                    initialize_algorithm(actors, topology, totalNodes, algorithm)
                    
                _ ->
                    IO.puts "you have entered the wrong algorithm name"
                    IO.puts "please use gossip or push-sum as an algorithm name in 3rd argument"
            end

        end
        
    children = [
      # Starts a worker by calling: Proj2.Worker.start_link(arg)
      # {Proj2.Worker, arg}
    ]

    # opts = [strategy: :one_for_one, name: Proj2.Supervisor]
    # Supervisor.start_link(children, opts)
    Supervisor.init(children, strategy: :one_for_one)
    end

    #initializing the topologies and starting the algorithm
    def initialize_algorithm(actors, topology, totalNodes, algorithm) do

        :ets.new(:count, [:set, :public, :named_table])
        :ets.insert(:count, {"spread", 0})
    
        # Determine Neighbor nodes as per requested topology
        neighbors =
        case topology do
            "full" ->
                  IO.puts "Implementing full topology"
                  Proj2.Topologies.creating_full_network(actors)
            "line" ->
                  IO.puts "Implementing line topology"
                  Proj2.Topologies.creating_line_network(actors)
            "rand2D" ->
                  IO.puts "Implementing random 2D topology"
                  Proj2.Topologies.creating_rand2D_network(actors)
            "3Dtorus" ->
                  IO.puts("Implementing 3D torus grid topology")
                  Proj2.Topologies.creating_3Dtorus_network(actors)
            "honeycomb" ->
                  IO.puts("Implementing honeycomb topology")
                  Proj2.Topologies.creating_honeycomb_network(actors,topology)
            "randhoneycomb" ->
                  IO.puts("Implementing honeycomb topology with random neighbors")
                  Proj2.Topologies.creating_honeycomb_network(actors,topology)
             _ ->
                  IO.puts "Please use one of the full | line | rand2D | 3Dtorus | honeycomb | randhoneycomb as topology"
                  System.halt(0)
        end

        for  {pid, neighbors_pid}  <-  neighbors  do
            Proj2.Client.set_neighbors(pid, neighbors_pid)           #setting the neighbors
        end

        start_time = System.monotonic_time(:millisecond)    # start time of convergence

        case algorithm do
        "gossip" ->
            Proj2.Gossip.gossip_algorithm(actors, neighbors, totalNodes)
        "push-sum" ->
            Proj2.PushSum.push_sum_algorithm(actors, neighbors, totalNodes)
        end
        
        # printing the total convergence time by subtracting the current time from start-time.
        IO.puts "Convergence Time: " <> to_string(System.monotonic_time(:millisecond) - start_time) <> " milliseconds"
        System.halt(0)
    end

end