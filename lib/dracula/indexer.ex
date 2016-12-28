defmodule Dracula.Indexer do
  @doc ~S"""
  Indexes a list of file resource tuples.

  ## Examples

  Given a file resource tuple, `index/1` returns a list with a map for each
  resource. Each map has the following keys:

  * "directory" is the split directory path, relative from the root directory
  (like `["path", "to", "file"]` or ["about"]), and is copied from each file
  resource tuple.
  * "input_path" is the path to the file, relative from the current working
  directory, and is copied from each file resource tuple.
  * "output_path" is the file's output path, relative from the current working
  directory, and is built using the split directory path and the file's
  basename.

    iex> Dracula.Indexer.index([{[], "index.html"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "index.html",
        "output_path" => "_output/index.html"
      }
    ]}

    iex> Dracula.Indexer.index([{["about"], "about/index.html"}])
    {:ok, [
      %{
        "directory" => ["about"],
        "input_path" => "about/index.html",
        "output_path" => "_output/about/index.html"
      }
    ]}

    The path in the resource tuples is relative from the current working
    directory, so the output_path gets built using the split directory path (
    which is the path to the file's directory, relative from the root path)

    iex> Dracula.Indexer.index([{[], "path/to/file/index.html"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "path/to/file/index.html",
        "output_path" => "_output/index.html"
      }
    ]}
  """
  def index(resources) do
    index = resources
    |> Enum.map(fn({directory, input_path} = resource) ->
      %{
        "directory" => directory,
        "input_path" => input_path,
        "output_path" => Path.join("_output", relative_input_path(resource))
      }
    end)

    {:ok, index}
  end

  defp relative_input_path({[], path}), do: Path.basename(path)
  defp relative_input_path({[directory|tail], path}) do
    Path.join(directory, relative_input_path({tail, path}))
  end
end
