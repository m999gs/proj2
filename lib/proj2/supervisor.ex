defmodule Proj2.Supervisor do
    use Supervisor
    
    def start_link(state) do
        Supervisor.start_link(__MODULE__, state, name: __MODULE__)
    end

    def init({arg1,arg2,arg3}) do
        if arg1>1 do
            case arg3 do
                "gossip" ->
                    IO.puts("Initializing gossip algorithm")
                    
                "push-sum" ->
                    IO.puts("Initializing push sum algorithm")
                _ ->
                    IO.puts "you have entered the wrong algorithm name"
                    IO.puts "please use gossip or push-sum as an algorithm name in 3rd argument"
            end
        end
    end
end