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
  * "path" is the file's output path, relative from the output directory and
  prefixed with a / to be used to link between files on a web server. If the
  filename is index.html, it gets stripped from the end of the path.

    iex> Dracula.Indexer.index([{[], "foo.html"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "foo.html",
        "output_path" => "_output/foo.html",
        "path" => "/foo.html"
      }
    ]}

    iex> Dracula.Indexer.index([{["about"], "about/index.html"}])
    {:ok, [
      %{
        "directory" => ["about"],
        "input_path" => "about/index.html",
        "output_path" => "_output/about/index.html",
        "path" => "/about/"
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
        "output_path" => "_output/index.html",
        "path" => "/"
      }
    ]}
  """
  def index(resources) do
    index = resources
    |> Enum.map(fn({directory, input_path} = resource) ->
      %{
        "directory" => directory,
        "input_path" => input_path,
        "output_path" => output_path(resource),
        "path" => path(resource)
      }
    end)

    {:ok, index}
  end

  defp path(resource) do
    "/#{relative_path(resource)}" |> String.replace_trailing("index.html", "")
  end

  defp output_path(resource) do
    Path.join("_output", relative_path(resource))
  end

  defp relative_path({[], path}), do: Path.basename(path)
  defp relative_path({[directory|tail], path}) do
    Path.join(directory, relative_path({tail, path}))
  end
end
