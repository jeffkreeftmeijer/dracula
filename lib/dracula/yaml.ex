defmodule Dracula.YAML do
  @doc ~S"""
  Parses YAML using :yamerl, and converts the results to a map with string keys
  and values.

  ## Examples

    iex> Dracula.YAML.to_map("title: A YAML file")
    {:ok, %{"title" => "A YAML file"}}
  """
  def to_map(yaml) do
    :application.start(:yamerl)

    map = yaml
    |> :yamerl_constr.string
    |> List.first
    |> Enum.into(%{}, fn({key, value}) ->
      {to_string(key), to_string(value)}
    end)

    {:ok, map}
  end
end
