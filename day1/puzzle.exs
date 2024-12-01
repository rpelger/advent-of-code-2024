defmodule Puzzle do

  def solve_puzzle1() do
    "input.txt"
      |> read_input
      |> split_into_two_lists
      |> Enum.map(fn(list) -> Enum.sort(list) end)
      |> Enum.zip
      |> Enum.map(fn({x, y}) -> abs(x-y) end)
      |> Enum.sum
      |> IO.inspect
  end

  def solve_puzzle2() do
    [list1, list2] =
      "input.txt"
        |> read_input
        |> split_into_two_lists

    list1
      |> Enum.map(fn(x) -> find_occurrences_in(x, list2) end)
      |> Enum.filter(fn({_, occ}) -> occ > 0 end)
      |> Enum.map(fn({value, occ}) -> value * occ end)
      |> Enum.sum
      |> IO.inspect
  end

  def read_input(filename) do
    __ENV__.file
      |> Path.dirname
      |> Path.join(filename)
      |> File.read!()
  end

  def split_into_two_lists(input) do
    input
      |> String.replace("   ", ",") 
      |> String.replace("\n", ",") 
      |> String.trim_trailing(",") 
      |> String.split(",") 
      |> Enum.map(&Integer.parse/1) 
      |> Enum.map(fn({x, _}) -> x end) 
      |> Enum.with_index 
      |> Enum.split_with(fn({_, i}) -> rem(i, 2) == 0 end)
      |> Tuple.to_list
      |> Enum.map(fn(list) -> Enum.map(list, fn({x, _}) -> x end) end)
  end

  def find_occurrences_in(value, list) do
    {value, Enum.count(list, fn(x) -> x==value end)}
  end
end

Puzzle.solve_puzzle1()
Puzzle.solve_puzzle2()
