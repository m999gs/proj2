defmodule Proj2.Topologies do
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
            lowerlimit = level * number * number
            upperlimit = (level + 1) * number * number
            
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
    
        # ---------------------------------- HONEYCOMB ---------------------------------
        def determine_nodes_honeycomb(actors,topology) do
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
                Map.put(acc, j, (i + number))
      
              (j == 3) && (rem((i - 1), number) != (number - 1)) && ((i - 1) >= 0) ->
                Map.put(acc, j, (i - 1))
              
              (j == 4) && (rem((i + 1) , number) != 0) && ((i+1)< n) ->
                Map.put(acc, j, (i + 1))
                
              true ->
                acc 
              end 
            end)
      
            neighbors = Map.values(neighbors)
            
              neighbors =
            case topology do
              "randhoneycomb" ->
                neighbors ++ get_random_node(neighbors, i, n-1) 
              _ -> 
                neighbors
            end
      
            neighbor_pids = Enum.map(neighbors, fn x -> {:ok, n} = Map.fetch(indexed_actors, x)
              n end)
      
           {:ok, actor} = Map.fetch(indexed_actors, i)
           Map.put(acc, actor, neighbor_pids)
          end)
    
        end
        #  --------   Get Random neigbor for rand2D  --------
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