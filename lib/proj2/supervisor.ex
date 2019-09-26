defmodule Proj2.Supervisor do
    use Supervisor
    
    def start_link(init_arg) do
        Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    def init(init_arg) do
        IO.inspect (init_arg)
        {_pid, numNodes, topology, algorithm} = init_arg
        if numNodes>1 do
            case algorithm do
                "gossip" ->
                    IO.puts("Initializing gossip algorithm")
                    actor=create_actors(numNodes;

                "push-sum" ->
                    IO.puts("Initializing push sum algorithm")
                    actor=create_actors(numNodes);
                    
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

    def initializing_algorithm(numNodes, topology, algorithm, actors) do
        :ets.new(:count, [:set, :public, :named_table])
        :ets.insert(:count, {"spread", 0})
    
        # Determine Neighbor nodes as per requested topology
        neighbors =
        case topology do
            "full" ->
                _neighbors = determine_nodes_full(actors)
                IO.puts("Implementing full network topology")
            "line" -> 
                _neighbors = determine_nodes_full(actors)
                IO.puts("Implementing line topology")
            "rand2D" ->
                _neighbors = determine_nodes_full(actors)
                IO.puts("Implementing random 2D grid topology")
            "3Dtorus" ->
                _neighbors = determine_nodes_full(actors)
                IO.puts("Implementing 3D torus grid topology")
            "honeycomb" ->
                _neighbors = determine_nodes_full(actors)
                IO.puts("Implementing honeycomb topology")
            "randhoneycomb" ->
                _neighbors = determine_nodes_full(actors)
                IO.puts("Implementing honeycomb topology with random neighbors")
            _ ->
                IO.puts("Please enter a valid topology, e.g. line or honeycomb")
        end
        set_neighbors(neighbors)
        prev = System.monotonic_time(:millisecond)
    
        if (algorithm == "gossip") do
          # call gossip algorithm
          gossip(actors, neighbors, totalNodes)
        else
          # call push-sum algorithm
          push_sum(actors, neighbors, totalNodes)
        end
        IO.puts "Time to Converge: " <> to_string(System.monotonic_time(:millisecond) - prev) <> " ms"
        System.halt(0)

    end

end