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
    to the root directory, if present.

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

  Given a Markdown or Liquid file resource, both the path and output path are
  rewritten to use ".html" as its extension instead of ".md" or ".liquid"

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

    iex> Dracula.Indexer.index([{[], "foo.liquid", "{% comment %}\nfoo.liquid\n{% endcomment %}"}])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "foo.liquid",
        "output_path" => "_output/foo.html",
        "path" => "/foo.html",
        "contents" => "{% comment %}\nfoo.liquid\n{% endcomment %}",
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

    iex> Dracula.Indexer.index([{[], "index.liquid", "{% comment %}\nindex.liquid\n{% endcomment %}"}, {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"} ])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "index.liquid",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "{% comment %}\nindex.liquid\n{% endcomment %}",
        "layouts" => ["{% comment %}\n_layout.liquid\n{% endcomment %}"]
      }
    ]}

  If the file is in a subdirectory with a file named `_layout.liquid`, and the
  directory above has a `_layout.liquid` file as well, both get included in the
  "layouts" item, up to the root.

    iex> Dracula.Indexer.index([{["sub"], "sub/index.md", "<!-- sub/index.md -->"}, {["sub"], "_layout.liquid", "{% comment %}\nsub/_layout.liquid\n{% endcomment %}"}, {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"} ])
    {:ok, [
      %{
        "directory" => ["sub"],
        "input_path" => "sub/index.md",
        "output_path" => "_output/sub/index.html",
        "path" => "/sub/",
        "contents" => "<!-- sub/index.md -->",
        "layouts" => [
          "{% comment %}\nsub/_layout.liquid\n{% endcomment %}",
          "{% comment %}\n_layout.liquid\n{% endcomment %}"
        ]
      }
    ]}

  Layouts are only loaded for Markdown and Liquid files, so HTML files will
  always have an empty "layouts" item, even if there's a `_layout.liquid` file
  present in their input directories.

    iex> Dracula.Indexer.index([{[], "index.html", "<!-- index.html -->"}, {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"} ])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "index.html",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "<!-- index.html -->",
        "layouts" => []
      }
    ]}

  If there's a metadata file (named `_metadata.yml`) in the same directory as
  the resource, its contents get added to the resource.

    iex> Dracula.Indexer.index([{[], "index.md", "<!-- index.md -->"}, {[], "_metadata.yml", "title: The index"} ])
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "index.md",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "<!-- index.md -->",
        "layouts" => [],
        "title" => "The index"
      }
    ]}

  Like with layouts, metadata files in parent directories are included as well.
  If the file is in a subdirectory with a `_metadata.yml` file, and the
  directory above has one as well, both get merged into one. The metadata file
  closest to the resource overwrites its parents.

    iex> Dracula.Indexer.index([{["sub"], "sub/index.md", "<!-- sub/index.md -->"}, {["sub"], "_metadata.yml", "title: The subdirectory"}, {[], "_metadata.yml", "title: The index\ndescription: A description"}])
    {:ok, [
      %{
        "directory" => ["sub"],
        "input_path" => "sub/index.md",
        "output_path" => "_output/sub/index.html",
        "path" => "/sub/",
        "contents" => "<!-- sub/index.md -->",
        "layouts" => [],
        "title" => "The subdirectory",
        "description" => "A description"
      }
    ]}
  """
  def index(resources) do
    index = resources
    |> Enum.filter(fn({_, input_path, _}) ->
      !(input_path |> Path.basename |> String.starts_with?("_"))
    end)
    |> Enum.map(fn({directory, input_path, contents} = resource) ->
      metadata(resources, directory)
      |> Map.merge(%{
        "directory" => directory,
        "input_path" => input_path,
        "output_path" => output_path(resource),
        "path" => path(resource),
        "contents" => contents,
        "layouts" => layouts(resources, directory, input_path)
      })
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
    extname = Path.extname(filename)
    case Enum.member?(~w(.liquid .md), extname) do
      true -> filename |> String.replace_trailing(extname, ".html")
      false -> filename
    end
  end

  defp layouts(resources, [], target_path) do
    case [layoutable?(target_path) && layout_for(resources, [])] do
      [{_, _, contents}] -> [contents]
      _ -> []
    end
  end
  defp layouts(resources, directory, target_path) do
    parent_layouts = layouts(resources, directory |> Enum.drop(-1), target_path)
    case [layoutable?(target_path) && layout_for(resources, directory)] do
      [{_, _, contents}] -> [contents|parent_layouts]
      _ -> parent_layouts
    end
  end

  defp layout_for(resources, search_directory) do
    resources |> Enum.find(fn({directory, path, _}) ->
      directory == search_directory && Path.basename(path) == "_layout.liquid"
    end)
  end

  defp layoutable?(path) do
    ~w(.md .liquid) |> Enum.member?(Path.extname(path))
  end

  defp metadata(resources, []) do
    case metadata_for(resources, []) do
      {_, _, contents} ->
        {:ok, metadata} = Dracula.YAML.to_map(contents)
        metadata
      _ -> %{}
    end
  end
  defp metadata(resources, directory) do
    parent_metadata = metadata(resources, directory |> Enum.drop(-1))
    case metadata_for(resources, directory) do
      {_, _, contents} ->
        {:ok, metadata} = Dracula.YAML.to_map(contents)
        Map.merge(parent_metadata, metadata)
      _ -> parent_metadata
    end
  end

  defp metadata_for(resources, search_directory) do
    resources |> Enum.find(fn({directory, path, _}) ->
      directory == search_directory && Path.basename(path) == "_metadata.yml"
    end)
  end
end
