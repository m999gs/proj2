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

                    case topology do
                        "full-network" ->
                            IO.puts("Implementing full network topology")
                            #initialization of the network happens here, its child nodes are decided, and a message is sent across neighbors
                        "line" -> 
                            IO.puts("Implementing line topology")
                        "random-2d-grid" ->
                            IO.puts("Implementing random 2D grid topology")
                        "3d-torus-grid" ->
                            IO.puts("Implementing 3D torus grid topology")
                        "honeycomb" ->
                            IO.puts("Implementing honeycomb topology")
                        "honeycomb-random" ->
                            IO.puts("Implementing honeycomb topology with random neighbors")

                        _ ->
                            IO.puts("Please enter a valid topology, e.g. line or honeycomb")
                    end
                "push-sum" ->
                    IO.puts("Initializing push sum algorithm")

                    case topology do
                        "full-network" ->
                            IO.puts("Implementing full network topology")
                        "line" -> 
                            IO.puts("Implementing line topology")
                        "random-2d-grid" ->
                            IO.puts("Implementing random 2D grid topology")
                        "3d-torus-grid" ->
                            IO.puts("Implementing 3D torus grid topology")
                        "honeycomb" ->
                            IO.puts("Implementing honeycomb topology")
                        "honeycomb-random" ->
                            IO.puts("Implementing honeycomb topology with random neighbors")

                        _ ->
                            IO.puts("Please enter a valid topology, e.g. line or honeycomb")
                    end
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
end