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

    iex> Dracula.Indexer.index(
    ...>   [{["about"], "about/index.html", "<!-- about/index.html -->"}]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [{[], "path/to/file/index.html", "<!-- index.html -->"}]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [{[], "foo.liquid", "{% comment %}\nfoo.liquid\n{% endcomment %}"}]
    ...> )
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

  If a Markdown or Liquid file has the same name as the directory, it's path and
  output path are rewritten to "index.html".

    iex> Dracula.Indexer.index([{["sub"], "sub/sub.md", "<!-- sub/sub.md -->"}])
    {:ok, [
      %{
        "directory" => ["sub"],
        "input_path" => "sub/sub.md",
        "output_path" => "_output/sub/index.html",
        "path" => "/sub/",
        "contents" => "<!-- sub/sub.md -->",
        "layouts" => []
      }
    ]}

  If there's a file named `_layout.liquid` in the same directory as the
  resource, its contents get included in the "layouts" item.

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {[], "index.md", "<!-- index.md -->"},
    ...>     {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"}
    ...>   ]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {[], "index.liquid", "{% comment %}\nindex.liquid\n{% endcomment %}"},
    ...>     {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"}
    ...>   ]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {["sub"], "sub/index.md", "<!-- sub/index.md -->"},
    ...>     {["sub"], "_layout.liquid", "{% comment %}\nsub/_layout.liquid\n{% endcomment %}"},
    ...>     {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"}
    ...>   ]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {[], "index.html", "<!-- index.html -->"},
    ...>     {[], "_layout.liquid", "{% comment %}\n_layout.liquid\n{% endcomment %}"}
    ...>   ]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {[], "index.md", "<!-- index.md -->"},
    ...>     {[], "_metadata.yml", "title: The index"}
    ...>   ]
    ...> )
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

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {["sub"], "sub/index.md", "<!-- sub/index.md -->"},
    ...>     {["sub"], "_metadata.yml", "title: The subdirectory"},
    ...>     {[], "_metadata.yml", "title: The index\ndescription: A description"}
    ...>   ]
    ...> )
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

  Subresources are resources in directories with an underscore. These
  underscored directories get removed from the output path.

    iex> Dracula.Indexer.index(
    ...>   [{["_about"], "_about/index.html", "<!-- _about/index.html -->"}]
    ...> )
    {:ok, [
      %{
        "directory" => ["_about"],
        "input_path" => "_about/index.html",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "<!-- _about/index.html -->",
        "layouts" => []
      }
    ]}

  Subresources get duplicated into their parents' resources, to allow
  referencing subresources in template files.

    iex> Dracula.Indexer.index(
    ...>   [
    ...>     {[], "index.html", "<!-- index.html -->"},
    ...>     {["_articles", "article"], "_articles/article/index.html", "<!-- _articles/article/index.html -->"},
    ...>     {["_articles", "article"], "_articles/article/_metadata.yml", "title: An article"},
    ...>     {["_articles", "another_article"], "_articles/another_article/index.html", "<!-- _articles/another_article/index.html -->"}
    ...>   ]
    ...> )
    {:ok, [
      %{
        "directory" => [],
        "input_path" => "index.html",
        "output_path" => "_output/index.html",
        "path" => "/",
        "contents" => "<!-- index.html -->",
        "layouts" => [],
        "articles" => [
          %{
            "directory" => ["_articles", "article"],
            "input_path" => "_articles/article/index.html",
            "output_path" => "_output/article/index.html",
            "path" => "/article/",
            "contents" => "<!-- _articles/article/index.html -->",
            "layouts" => [],
            "title" => "An article"
          },
          %{
            "directory" => ["_articles", "another_article"],
            "input_path" => "_articles/another_article/index.html",
            "output_path" => "_output/another_article/index.html",
            "path" => "/another_article/",
            "contents" => "<!-- _articles/another_article/index.html -->",
            "layouts" => []
          }
        ]
      },
      %{
        "directory" => ["_articles", "article"],
        "input_path" => "_articles/article/index.html",
        "output_path" => "_output/article/index.html",
        "path" => "/article/",
        "contents" => "<!-- _articles/article/index.html -->",
        "layouts" => [],
        "title" => "An article"
      },
      %{
        "directory" => ["_articles", "another_article"],
        "input_path" => "_articles/another_article/index.html",
        "output_path" => "_output/another_article/index.html",
        "path" => "/another_article/",
        "contents" => "<!-- _articles/another_article/index.html -->",
        "layouts" => []
      }
    ]}
  """
  def index(resources) do
    index = resources
    |> without_underscored_files
    |> Enum.map(fn(resource) -> index(resource, resources) end)

    {:ok, index}
  end

  def index({directory, input_path, contents} = resource, resources) do
    subresources(resources, directory)
    |> Map.merge(metadata(resources, directory))
    |> Map.merge(%{
      "directory" => directory,
      "input_path" => input_path,
      "output_path" => output_path(resource),
      "path" => path(resource),
      "contents" => contents,
      "layouts" => layouts(resources, directory, input_path)
    })
  end

  defp without_underscored_files([]), do: []
  defp without_underscored_files([{_, input_path, _} = resource|tail]) do
    case input_path |> Path.basename |> String.starts_with?("_") do
      false -> [resource|without_underscored_files(tail)]
      true -> without_underscored_files(tail)
    end
  end

  defp path(resource) do
    "/#{relative_path(resource)}" |> String.replace_trailing("index.html", "")
  end

  defp output_path(resource) do
    Path.join("_output", relative_path(resource))
  end

  defp relative_path(path) when is_binary(path) do
    relative_path({[], path})
  end

  defp relative_path({[], path}) do
    path
    |> Path.basename
    |> with_output_extension
  end
  defp relative_path({[directory], path}) do
    relative_output_path = path
    |> with_output_filename(directory)
    |> relative_path

    case String.starts_with?(directory, "_") do
      false -> Path.join(directory, relative_output_path)
      true -> relative_output_path
    end
  end
  defp relative_path({[directory|tail], path}) do
    relative_path = relative_path({tail, path})
    case String.starts_with?(directory, "_") do
      false -> Path.join(directory, relative_path)
      true -> relative_path
    end
  end
  defp relative_path({directories, path, _contents}) do
    relative_path({directories, path})
  end

  defp with_output_filename(path, directory) do
    case directory == Path.basename(path, Path.extname(path)) do
      true -> String.replace_trailing(path, Path.basename(path), "index.html")
      false -> path
    end
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
        YamlElixir.read_from_string(contents)
      _ -> %{}
    end
  end
  defp metadata(resources, directory) do
    parent_metadata = metadata(resources, directory |> Enum.drop(-1))
    case metadata_for(resources, directory) do
      {_, _, contents} ->
        metadata = YamlElixir.read_from_string(contents)
        Map.merge(parent_metadata, metadata)
      _ -> parent_metadata
    end
  end

  defp metadata_for(resources, search_directory) do
    resources |> Enum.find(fn({directory, path, _}) ->
      directory == search_directory && Path.basename(path) == "_metadata.yml"
    end)
  end

  defp subresources(resources, search_directory) do
    resources
    |> without_underscored_files
    |> Enum.filter(fn(resource) ->
      select_subresource(resource, search_directory)
    end)
    |> to_subresources(resources)
  end

  def select_subresource({[], _, _}, _search_directory), do: false
  def select_subresource({rest, _, _}, []) do
    rest |> List.first |> String.starts_with?("_")
  end
  def select_subresource(_resource, _search_directory), do: false

  def to_subresources([], _), do: %{}
  def to_subresources([{[directory|_], _, _} = subresource|tail], resources) do
    key = String.replace_leading(directory, "_", "")

    {_, subresources} = to_subresources(tail, resources)
    |> Map.get_and_update(key, fn(current_value) ->
      new_value = case current_value do
        nil -> [index(subresource, resources)]
        _ -> [index(subresource, resources)|current_value]
      end

      {current_value, new_value}
    end)

    subresources
  end
end
