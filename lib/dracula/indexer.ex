defmodule Dracula.Indexer do
  @doc ~S"""
  Indexes a list of file resource tuples.

  ## Examples
    iex> Dracula.Indexer.index([{[], "index.html"}])
    {:ok, [%{"directory" => [], "input_path" => "index.html"}]}

    iex> Dracula.Indexer.index([{["about"], "about/index.html"}])
    {:ok, [%{"directory" => ["about"], "input_path" => "about/index.html"}]}
  """
  def index(resources) do
    index = resources
    |> Enum.map(fn({directory, input_path}) ->
      %{"directory" => directory, "input_path" => input_path}
    end)

    {:ok, index}
  end
end
