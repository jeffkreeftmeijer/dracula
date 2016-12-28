defmodule Dracula.Indexer do
  @doc ~S"""
  Indexes a list of file resource tuples.

  ## Examples
    iex> Dracula.Indexer.index([{[], "index.html"}])
    {:ok, [%{"directory" => [], "path" => "index.html"}]}
  """
  def index([{directory, path}]) do
    {:ok, [%{"directory" => directory, "path" => path}]}
  end
end
