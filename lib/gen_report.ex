defmodule GenReport do
  alias GenReport.Parser

  @names [
    "daniele",
    "mayk",
    "giuliano",
    "cleiton",
    "jakeliny",
    "joseph",
    "diego",
    "danilo",
    "rafael",
    "vinicius"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  defp sum_values([name, hours, _day, _month, _year], %{"all_hours" => all_hours}) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    build_report(all_hours)
  end

  defp report_acc do
    people = Enum.into(@names, %{}, &{&1, 0})

    %{"all_hours" => people}
  end

  defp build_report(all_hours), do: %{"all_hours" => all_hours}
end
