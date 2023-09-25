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

  @years [2016, 2017, 2018, 2019, 2020]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Insira uma list de arquivos"}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)

    hours_per_month = merge_maps(hours_per_month1, hours_per_month2)

    hours_per_year = merge_maps(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn
      _key, value1, value2 when is_map(value1) and is_map(value2) -> merge_maps(value1, value2)
      _key, value1, value2 -> value1 + value2
    end)
  end

  defp sum_values([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    working_hours_per_month =
      Map.put(hours_per_month[name], month, hours_per_month[name][month] + hours)

    working_hours_per_year =
      Map.put(hours_per_year[name], year, hours_per_year[name][year] + hours)

    hours_per_month = Map.put(hours_per_month, name, working_hours_per_month)

    hours_per_year = Map.put(hours_per_year, name, working_hours_per_year)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc do
    people = Enum.into(@names, %{}, &{&1, 0})
    months = Enum.into(@months, %{}, &{&1, 0})
    years = Enum.into(@years, %{}, &{&1, 0})

    hours_per_month = Enum.into(@names, %{}, &{&1, months})
    hours_per_year = Enum.into(@names, %{}, &{&1, years})

    build_report(people, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
