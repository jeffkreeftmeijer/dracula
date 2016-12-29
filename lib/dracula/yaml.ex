defmodule Dracula.YAML do
  @doc ~S"""
  Parses YAML using :yamerl, and converts the results to a map with string keys
  and values.

  ## Examples

    iex> Dracula.YAML.to_map("title: A YAML file")
    {:ok, %{"title" => "A YAML file"}}

    iex> Dracula.YAML.to_map("sub:\n  title: A YAML file")
    {:ok, %{"sub" => %{"title" => "A YAML file"}}}
  """
  def to_map(yaml) do
    :application.start(:yamerl)

    map = yaml
    |> :yamerl_constr.string
    |> List.first
    |> Enum.into(%{}, &to_strings/1)

    {:ok, map}
  end

  def to_strings([{key, value}]) do
    [to_strings({key, value})] |> Enum.into(%{})
  end
  def to_strings({key, value}), do: {to_string(key), to_strings(value)}
  def to_strings(value) when is_list(value), do: to_string(value)
end
