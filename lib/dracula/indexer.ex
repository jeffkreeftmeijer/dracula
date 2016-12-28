defmodule Dracula.Indexer do
  @doc ~S"""
  Indexes a list of file resource tuples.

  ## Examples
    iex> Dracula.Indexer.index([{[], "index.html"}])
    {:ok, [%{"directory" => [], "path" => "index.html"}]}

    iex> Dracula.Indexer.index([{["about"], "about/index.html"}])
    {:ok, [%{"directory" => ["about"], "path" => "about/index.html"}]}
  """
  def index(resources) do
    index = resources
    |> Enum.map(fn({directory, path}) ->
      %{"directory" => directory, "path" => path}
    end)

    {:ok, index}
  end
end
