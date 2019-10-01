defmodule Proj2.Topologies do
  # each actor is connected to every other actor
  def creating_full_network(actors) do
    Enum.reduce(actors, %{}, fn (current_actor, acc) ->  
      Map.put(acc, current_actor, Enum.filter(actors, fn actor -> actor != current_actor end)) 
    end)
  end
  
  #all the actors are connected in the form of a line
  def creating_line_network(actors) do
    n = length(actors)
    actor_index = Stream.with_index(actors) |> Enum.reduce(%{}, fn({actor , index}, acc) -> Map.put(acc, index, actor) end)
    Enum.reduce(0..n-1, %{}, fn (x, acc) ->
      neighbors =
        cond do
          x == 0 -> [1]
          x == n-1 -> [n - 2]
          true -> [(x - 1), (x + 1)]
        end

        neighbor_pids = Enum.map(neighbors, fn i ->
          {:ok, n} = Map.fetch(actor_index, i)
          n end)

        {:ok, actor} = Map.fetch(actor_index, x)
        Map.put(acc, actor, neighbor_pids)
    end)
  end

  #actors are arranged in the form of a grid, are connected if with 0.1 distance of each other
  def creating_rand2D_network(actors) do
    n = length(actors)
    actor_index = Stream.with_index(actors) |> Enum.reduce(%{}, fn({actor , index}, acc) -> Map.put(acc, index, actor) end)
  
    map = Enum.reduce(0..n-1, %{}, fn (index, acc)->
      coordinates = {(Enum.random(0..10)/100),(Enum.random(0..10)/100)}
      Map.put(acc, index, coordinates)
    end)

    Enum.reduce(0..n-1, %{}, fn i, acc -> 
      {:ok, {currentx, currenty}} = Map.fetch(map, i)
      
      tempMap = Map.delete(map, i)
      remainingKeys = Map.keys(tempMap)
      neighbors = Enum.reduce(remainingKeys, %{}, fn (key, acc) -> 
        {:ok, {coordx, coordy}} = Map.fetch(tempMap, key)
        cond do
          (abs(currentx - coordx) + abs(currenty - coordy)) < 0.1 ->
            Map.put(acc, key, i)
          true ->
            acc
          end
      end)
      neighbors = Map.keys(neighbors)

      neighbor_pids = Enum.map(neighbors, fn x -> {:ok, n} = Map.fetch(actor_index, x)
        n end)
    
      {:ok, actor} = Map.fetch(actor_index, i)
      Map.put(acc, actor, neighbor_pids)
    end)
  end

  # Creates a 3D torus grid in which every actor have exactly six neighbors
  def creating_3Dtorus_network(actors) do
    n = length(actors)
    number = trunc(:math.floor(:math.pow(n, 1/3)))
    actor_index = Stream.with_index(actors) |> Enum.reduce(%{}, fn({actor , index}, acc) -> Map.put(acc, index, actor) end)
    
    Enum.reduce(0..n-1, %{}, fn i,acc ->
        layer = number*number
        level = trunc(:math.floor(i / layer))
        lowerlimit = level * layer
        upperlimit = (level + 1) * layer
        
        neighbors = Enum.reduce(1..6, %{}, fn (j, acc) ->
            # Get 6 neighbors
            cond do
            (j == 1) ->   #top
              if ((i - number) >= lowerlimit) do
                Map.put(acc, j, (i - number))
              else 
                Map.put(acc, j, Enum.reduce( i..n , i , fn(_,acc)-> if acc < upperlimit && acc < n do acc + number else acc end end) - number)
              end 
              
            (j == 2) ->   #bottom
              if ((i + number) < upperlimit) && ((i+number)< n) do
                Map.put(acc, j, (i+number))
              else
                Map.put(acc, j, Enum.reduce(i..0, i , fn(_,acc)-> if acc >= lowerlimit do acc - number else acc end end) + number)
              end

            (j == 3) ->   #left
              if (rem((i - 1), number) != (number - 1)) && ((i - 1) >= 0) do
                Map.put(acc, j, (i - 1))
              else
                Map.put(acc, j, if (i + number - 1)<n do (i + number - 1) else (n - 1) end)
              end

            (j == 4) ->   #right
              if (rem((i + 1) , number) != 0) && ((i+1)< n) do
                Map.put(acc, j, (i + 1))
              else
                Map.put(acc, j, if (i == n - 1 ) do (Enum.reduce(lowerlimit..n, lowerlimit , fn(_,acc)-> if acc < n do acc + number else acc end end) - number) else (i - number + 1) end)
              end

            (j == 5) ->   #back
              if (i + (number * number) < n) do
                Map.put(acc, j, (i + layer))
              else 
                Map.put(acc, j, Enum.reduce(i..0, i , fn(_,acc)-> if acc > 0 do acc - layer else acc end end) + layer)
              end

            (j == 6) ->   #front
              if (i - (number * number) >= 0) do
                Map.put(acc, j, (i - layer))
              else
                Map.put(acc, j, Enum.reduce( i..n, i , fn(_,acc)-> if acc < n do acc+layer else acc end end) -layer)
              end

            end #end of cond do
          end)

        neighbors = Map.values(neighbors) # Mapping the neighbors after assigning their values.

        neighbor_pids = Enum.map(neighbors, fn x ->
          {:ok, n} = Map.fetch(actor_index, x)
          n end)

        {:ok, actor} = Map.fetch(actor_index, i)
        Map.put(acc, actor, neighbor_pids)
      end)
    end

  #Actors are aranged in a honeycomb structure
  def creating_honeycomb_network(actors,topology) do
    n = length(actors)
    number = trunc(:math.floor(:math.pow(n, 1/3)))
    number = (2* number) + 1
    actor_index = Stream.with_index(actors) |> Enum.reduce(%{}, fn({actor , index}, acc) -> Map.put(acc, index, actor) end)

    Enum.reduce(0..n-1, %{}, fn i,acc ->
      
      neighbors = Enum.reduce(1..3, %{}, fn (j, acc) ->

        cond do
        (j == 1) && rem(i,2)!=0 && ((i - number) >= 0) ->         # odd top addition
          Map.put(acc, j, (i - number))

        (j == 1) && rem(i,2)==0 && ((i + number) < n) ->          # even bottom addition
          Map.put(acc, j, (i + number))

        (j == 2) && (rem((i - 1), number) != (number - 1)) && ((i - 1) >= 0) -> # left addition
          Map.put(acc, j, (i - 1))
        
        (j == 3) && (rem((i + 1) , number) != 0) && ((i+1)< n) -> #right addition
          Map.put(acc, j, (i + 1))          
        true ->
          acc 
        end 
      end)

      neighbors = Map.values(neighbors)

        neighbors =
      case topology do
        "randhoneycomb" ->
          neighbors ++ get_random_node(n-1, i, neighbors) 
        _ -> 
          neighbors
      end

      neighbor_pids = Enum.map(neighbors, fn x -> {:ok, n} = 
      Map.fetch(actor_index, x)
        n end)

      {:ok, actor} = Map.fetch(actor_index, i)
      Map.put(acc, actor, neighbor_pids)
    end)
  end

  #Getting a random node for random honeycomb
  def get_random_node(totalNodes, i, neighbors) do
      random_index = :rand.uniform(totalNodes)
      neighbors = neighbors ++ [i]
      if(Enum.member?(neighbors, random_index)) do
        get_random_node(totalNodes, i, neighbors)
      else
        [random_index]
      end
  end

end