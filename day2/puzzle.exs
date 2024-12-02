defmodule Puzzle do

  def solve_puzzle(part) do
    "input.txt"
      |> read_input
      |> split_to_integer_list
    # |> Enum.drop(-990)
      |> Enum.map(fn(each_list) -> to_report(each_list) end)
      |> Enum.map(fn(report) -> is_safe(report) end)
      |> Enum.map(fn({safe, report}) -> apply_dampening(safe, report, part) end)
      |> Enum.filter(fn({safe,_}) -> safe == :safe end)
      |> Enum.count
      |> IO.inspect
  end

  def read_input(filename) do
    __ENV__.file
      |> Path.dirname
      |> Path.join(filename)
      |> File.read!()
  end

  def split_to_integer_list(content) do
    content 
      |> String.split("\n", trim: true)
      |> Enum.map(fn(x) -> String.split(x, " ") end)
      |> Enum.map(fn(each_list) -> 
            Enum.map(each_list, fn(x) ->
              Integer.parse(x) 
                |> Tuple.to_list
                |> List.first
            end)
         end)
  end

  def to_report(input_list) do
    init = %{last: :init, list: :init}
    result = 
      input_list
        |> List.foldl(init, fn(cur, %{last: last, list: list}) -> 
            if(last == :init) do
              %{last: cur, list: [{:init, cur}]}
            else 
              calc_step(cur, last, list) 
            end 
          end)
    incs = result.list |> Enum.count(fn({dir,_}) -> dir == :inc end)
    decs = result.list |> Enum.count(fn({dir,_}) -> dir == :dec end)
    noks = result.list |> Enum.count(fn({dir,_}) -> dir == :nok end)
    init = result.list |> Enum.count(fn({dir,_}) -> dir == :init end)
    total = Enum.count(result.list) 
    
    type = 
      cond do
        incs - decs  > 0 -> :inc
        incs - decs  < 0 -> :dec
        incs - decs == 0 -> :eql
      end
    
    %{
      type: type, 
      total: total,
      counts: %{
        inc: incs, 
        dec: decs, 
        nok: noks, 
        init: init
      },
      original: input_list,
      parsed: result.list
    }
  end

  def calc_step(cur, last, list) do
    step = cur - last
    is_valid = abs(step) >=1 and abs(step) <= 3 
    is_inc = step > 0

    case({is_valid, is_inc}) do
      {false, _} -> %{last: cur, list: list ++ [{:nok, cur}]}
      {true, true} -> %{last: cur, list: list ++ [{:inc, cur}]}
      {true, false} -> %{last: cur, list: list ++ [{:dec, cur}]}
      _ -> %{last: cur, list: list ++ [{:err, cur}]}
    end
  end

  def is_safe(report) do
    safe = 
      case report.type do
        :inc -> report.counts.nok == 0 and report.counts.dec == 0 
        :dec -> report.counts.nok == 0 and report.counts.inc == 0
        :eql -> false
      end
    if safe do {:safe, report} else {:unsafe, report} end
  end
  
  def apply_dampening(:safe  , report, _any   ), do: {:safe, report}
  def apply_dampening(:unsafe, report, :normal), do: {:unsafe, report}
  def apply_dampening(:unsafe, report, :damped) do
    Enum.into(0..Enum.count(report.original)-1, []) 
      |> Enum.map(fn(i) -> List.delete_at(report.original, i) end) 
      |> Enum.map(fn(alt) -> to_report(alt) end)
      |> Enum.map(fn(report) -> is_safe(report) end)
      |> Enum.find({:unsafe, report}, fn({safe,_}) -> safe == :safe end)
  end

end

Puzzle.solve_puzzle(:normal)
Puzzle.solve_puzzle(:damped)

