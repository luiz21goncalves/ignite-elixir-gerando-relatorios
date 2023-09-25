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

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  defp sum_values([name, hours, _day, month, _year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month
       }) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    working_hours_per_month =
      Map.put(hours_per_month[name], month, hours_per_month[name][month] + hours)

    hours_per_month = Map.put(hours_per_month, name, working_hours_per_month)

    build_report(all_hours, hours_per_month)
  end

  defp report_acc do
    people = Enum.into(@names, %{}, &{&1, 0})
    months = Enum.into(@months, %{}, &{&1, 0})

    hours_per_month = Enum.into(@names, %{}, &{&1, months})

    build_report(people, hours_per_month)
  end

  defp build_report(all_hours, hours_per_month) do
    %{"all_hours" => all_hours, "hours_per_month" => hours_per_month}
  end
end
