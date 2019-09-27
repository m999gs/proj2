defmodule Proj2.Supervisor do
    use Supervisor
    
    def start_link(init_arg) do
        Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    def init(init_arg) do
        IO.inspect (init_arg)
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
                  _neighbors = determine_nodes_full(actors)
            "line" ->
                  IO.puts "Implementing line topology"
                  _neighbors = determine_nodes_line(actors)
            "rand2D" ->
                  IO.puts "Implementing random 2D topology"
                  _neighbors = determine_nodes_rand2D(actors)
            "3Dtorus" ->
                  IO.puts("Implementing 3D torus grid topology")
                  _neighbors = determine_nodes_3D(actors)
            # "honeycomb" ->
            #       IO.puts("Implementing honeycomb topology")
            #       _neighbors = determine_nodes_honeycomb(actors)
            # "randhoneycomb" ->
            #       IO.puts("Implementing honeycomb topology with random neighbors")
            #       _neighbors = determine_nodes_full(actors)
             _ ->
                  IO.puts "Please use one of full/3D/rand2D/torus/line/impLine as topology"
                  System.halt(0)
          end
            
        set_neighbors(neighbors)
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

    #  ---------------------   Determine neighbor nodes for full topology  ---------------------
    def determine_nodes_full(actors) do
        Enum.reduce(actors, %{}, fn (x, acc) ->  Map.put(acc, x, Enum.filter(actors, fn y -> y != x end)) end)
    end
    
  #  ---------------------   Determine neighbor nodes for line topology  ---------------------
  def determine_nodes_line(actors) do
    indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,number}, acc) -> Map.put(acc, number, y) end)
    n = length(actors)
    Enum.reduce(0..n-1, %{}, fn (x, acc) ->
        neighbors =
          cond do
            x == 0 -> [1]
            x == n-1 -> [n - 2]
            true -> [(x - 1), (x + 1)]
          end

          neighbor_pids = Enum.map(neighbors, fn i ->
            {:ok, n} = Map.fetch(indexed_actors, i)
            n end)

          {:ok, actor} = Map.fetch(indexed_actors, x)
          Map.put(acc, actor, neighbor_pids)
          end)
  end

  #  ---------------------   Determine neighbor nodes for 2D topology  ---------------------
  def determine_nodes_rand2D(actors) do

    n = length(actors)
    number = trunc(:math.ceil(:math.sqrt(n)))
    indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,number}, acc) -> Map.put(acc, number, y) end)

    #final_neighbors = Enum.reduce(0..n-1, %{}, fn i,acc ->
    Enum.reduce(0..n-1, %{}, fn i,acc ->
      neighbors = Enum.reduce(1..4, %{}, fn (j, acc) ->
        cond do
        (j == 1) && ((i - number) >= 0) ->
          Map.put(acc, j, (i - number))

        (j == 2) && ((i + number) < n) ->
          Map.put(acc, j, (i+number))

        (j == 3) && (rem((i - 1), number) != (number - 1)) && ((i - 1) >= 0) ->
          Map.put(acc, j, (i - 1))
        
        (j == 4) && (rem((i + 1) , number) != 0) && ((i+1)< n) ->
          Map.put(acc, j, (i + 1))
          
        true ->
          acc 
        end 
      end)

      neighbors = Map.values(neighbors)

      neighbors = neighbors ++ get_random_node(neighbors, i, n-1)

      neighbor_pids = Enum.map(neighbors, fn x -> {:ok, n} = Map.fetch(indexed_actors, x)
        n end)

     {:ok, actor} = Map.fetch(indexed_actors, i)
     Map.put(acc, actor, neighbor_pids)
    end)
  end
  
#  ---------------------   Determine neighbor nodes for 3D topology  ---------------------
def determine_nodes_3D(actors) do
    n = length(actors)
    number = trunc(:math.ceil(cbrt(n)))
    indexed_actors = Stream.with_index(actors, 0) |> Enum.reduce(%{}, fn({y,number}, acc) -> Map.put(acc, number, y) end)
    
    #final_neighbors = Enum.reduce(0..n-1, %{}, fn i,acc ->
    Enum.reduce(0..n-1, %{}, fn i,acc ->
        level = trunc(:math.floor(i / (number * number)))
        upperlimit = (level + 1) * number * number
        lowerlimit = level * number * number
        neighbors = Enum.reduce(1..6, %{}, fn (j, acc) ->
           # Get 6 neighbors
           cond do
            (j == 1) && ((i - number) >= lowerlimit) -> 
              Map.put(acc, j, (i - number))
            (j == 2) && ((i + number) < upperlimit) && ((i+number)< n) ->
              Map.put(acc, j, (i+number))
            (j == 3) && (rem((i - 1), number) != (number - 1)) && ((i - 1) >= 0) ->
              Map.put(acc, j, (i - 1))
            (j == 4) && (rem((i + 1) , number) != 0) && ((i+1)< n) ->
              Map.put(acc, j, (i + 1))
            (j == 5) && (i + (number * number) < n) ->
              Map.put(acc, j, (i + (number * number)))
            (j == 6) && (i - (number * number) >= 0) ->
              Map.put(acc, j, (i - (number * number)))
            true ->
              acc 
            end
          end)

        neighbors = Map.values(neighbors)

        neighbor_pids = Enum.map(neighbors, fn x ->
          {:ok, n} = Map.fetch(indexed_actors, x)
          n end)
  
       {:ok, actor} = Map.fetch(indexed_actors, i)
       Map.put(acc, actor, neighbor_pids)
      end)
    end
    
    #  ------------------------   Set neighbors  ------------------------
    def set_neighbors(neighbors) do
        for  {number, y}  <-  neighbors  do
        Proj2.Client.set_neighbors(number, y)
        end
    end

    #  --------   Get Random neigbor for rand2D, imp3D, impLine  --------
    def get_random_node(neighbors, i, totalNodes) do
        random_node_index =  :rand.uniform(totalNodes)
        neighbors = neighbors ++ [i]
        if(Enum.member?(neighbors, random_node_index)) do
        get_random_node(neighbors, i, totalNodes)
        else
        [random_node_index]
        end
    end

    #  ---------------   Determine cube root of a number  ---------------
    @spec cbrt(number) :: number
    def cbrt(x) when is_number(x) do
        cube = :math.pow(x, 1/3)
        cond do
        is_float(cube) == false ->
            cube
        true ->
            cube_ceil = Float.ceil(cube)
            cube_14 = Float.round(cube, 14)
            cube_15 = Float.round(cube, 15)
            if cube_14 != cube_15 and cube_14 == cube_ceil do
            cube_14
            else
            cube
            end
        end
    end
end