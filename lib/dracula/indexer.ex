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
  * "contents" are the file's contents, and they're copied from each file
    resource tuple.
  * "layouts" are the contents of each layout file from the file's directory, up
    to the root directory, if present

    iex> Dracula.Indexer.index([{[], "foo.html", "<!-- foo.html -->"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "foo.html",
        "output_path" => "_output/foo.html",
        "path" => "/foo.html",
        "contents" => "<!-- foo.html -->",
        "layouts" => []
      }
    ]}

    iex> Dracula.Indexer.index([{["about"], "about/index.html", "<!-- about/index.html -->"}])
    {:ok, [
      %{
        "directory" => ["about"],
        "input_path" => "about/index.html",
        "output_path" => "_output/about/index.html",
        "path" => "/about/",
        "contents" => "<!-- about/index.html -->",
        "layouts" => []
      }
    ]}

  The path in the resource tuples is relative from the current working
  directory, so the output_path gets built using the split directory path (
  which is the path to the file's directory, relative from the root path)

    iex> Dracula.Indexer.index([{[], "path/to/file/index.html", "<!-- index.html -->"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "path/to/file/index.html",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "<!-- index.html -->",
        "layouts" => []
      }
    ]}

  Given a Markdown file resource, both the path and output path are rewritten to
  use ".html" as its extension instead of ".md".

    iex> Dracula.Indexer.index([{[], "foo.md", "<!-- foo.md -->"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "foo.md",
        "output_path" => "_output/foo.html",
        "path" => "/foo.html",
        "contents" => "<!-- foo.md -->",
        "layouts" => []
      }
    ]}

  If there's a file named `_layout.liquid` in the same directory as the
  resource, its contents get included in the "layouts" item.

    iex> Dracula.Indexer.index([{[], "index.md", "<!-- index.md -->"}, {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"} ])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "index.md",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "<!-- index.md -->",
        "layouts" => ["{% comment %}\n_layout.liquid\n{% endcomment %}"]
      }
    ]}
  """
  def index(resources) do
    index = resources
    |> Enum.filter(fn({_, input_path, _}) ->
      !(input_path |> Path.basename |> String.starts_with?("_"))
    end)
    |> Enum.map(fn({directory, input_path, contents} = resource) ->
      %{
        "directory" => directory,
        "input_path" => input_path,
        "output_path" => output_path(resource),
        "path" => path(resource),
        "contents" => contents,
        "layouts" => layouts(resources, directory)
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

  defp relative_path({[], path}) do
    path
    |> Path.basename
    |> with_output_extension
  end
  defp relative_path({[directory|tail], path}) do
    Path.join(directory, relative_path({tail, path}))
  end
  defp relative_path({directories, path, _contents}) do
    relative_path({directories, path})
  end

  defp with_output_extension(filename) do
    case Path.extname(filename) do
      ".md" -> String.replace_trailing(filename, ".md", ".html")
      _ -> filename
    end
  end

  defp layouts(resources, search_directory) do
    resource = resources |> Enum.find(fn({directory, path, _}) ->
      directory == search_directory && Path.basename(path) == "_layout.liquid"
    end)

    case resource do
      {_, _, contents} -> [contents]
      nil -> []
    end
  end
end
