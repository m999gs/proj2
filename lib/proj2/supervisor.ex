defmodule Proj2.Supervisor do
    use Supervisor
    
    def start_link({init_arg}) do
        Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    def init({arg1,arg2,arg3}) do
        if arg1>1 do
            case arg3 do
                "gossip" ->
                    IO.puts("Initializing gossip algorithm")

                    case arg2 do
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

                    case arg2 do
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
    end
end