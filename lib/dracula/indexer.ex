defmodule Dracula.Indexer do
  @moduledoc """
  Indexes source directories.
  """
  alias Dracula.{Renderer, Extractor}

  @doc """
  Indexes a directory.
  """
  def index(root), do: index(root, root)

  def index(directory, root) do
    subdirectory_index = directory
    |> subdirectories
    |> Enum.map(fn(path) ->
      index(path, root)
    end)
    |> Enum.reduce(%{}, fn(index, accumulator) ->
      Map.merge(index, accumulator)
    end)

    directory
    |> files
    |> Enum.map(fn(path) ->
      index_path(path, root, Path.relative_to(path, root))
    end)
    |> Enum.into(%{})
    |> Map.merge(subdirectory_index)
  end

  defp index_path(path, root, relative_path) do
    output_path = output_path_from_relative_path(relative_path)

    index = %{
      input_path: path,
      input_directory: Path.dirname(path),
      output_path: output_path,
      root_path: root
    }
    |> fetch_layouts
    |> fetch_contents
    |> fetch_metadata
    |> render_contents
    |> Map.drop([:layouts, :input_path, :output_path, :root_path, :input_directory])

    {output_path, index}
  end

  defp subdirectories(directory) do
    directory
    |> Path.join("*")
    |> Path.wildcard
    |> Enum.filter(&File.dir?/1)
    |> Enum.reject(fn(path) ->
      Path.basename(path) == "_output"
    end)
  end

  defp files(directory) do
    directory
    |> Path.join("*.{html,md,eex}")
    |> Path.wildcard
    |> Enum.reject(fn(path) ->
      path
      |> Path.basename
      |> String.starts_with?("_")
    end)
  end

  defp output_path_from_relative_path(path) do
    extname =  Path.extname(path)

    case [Path.basename(path, extname) == Path.dirname(path), extname] do
      [true, _] ->
        String.replace_trailing(path, Path.basename(path), "index.html")
      [_, ".md"] -> String.replace_trailing(path, ".md", ".html")
      [_, ".eex"] -> String.replace_trailing(path, ".eex", ".html")
      _ -> path
    end
  end

  defp path_from_output_path(output_path) do
    String.replace_trailing("/#{output_path}", "index.html", "")
  end

  defp fetch_contents(%{input_path: input_path} = index) do
    Map.put(index, :contents, File.read!(input_path))
  end

  defp render_contents(%{input_path: input_path, layouts: layouts, metadata: metadata, contents: contents} = index) do
    Map.put(
      index,
      :contents,
      Renderer.render(contents, Path.extname(input_path), metadata, layouts)
    )
  end

  defp fetch_layouts(%{input_directory: directory, root_path: root_path} = index) do
    layouts = directory
    |> do_fetch_layouts(root_path, [])
    |> Enum.reverse

    Map.put(index, :layouts, layouts)
  end

  defp do_fetch_layouts(directory, accumulator) do
    do_fetch_layouts(directory, directory, accumulator)
  end
  defp do_fetch_layouts(directory, directory, accumulator) do
    case directory
    |> Path.join("_layout.eex")
    |> File.read do
      {:ok, layout} -> [layout|accumulator]
      _ -> accumulator
    end
  end
  defp do_fetch_layouts(directory, root, accumulator) do
    do_fetch_layouts(
      Path.dirname(directory),
      root,
      do_fetch_layouts(directory, accumulator)
    )
  end

  defp fetch_metadata(%{input_directory: directory, output_path: output_path, contents: contents} = index) do
    metadata = case directory
    |> Path.join("_metadata.yml")
    |> File.read do
      {:ok, metadata} ->
        metadata
        |> YamlElixir.read_from_string
        |> Enum.map(fn({key, value}) ->
          {String.to_atom(key), value}
        end)
      _ -> []
    end
    |> Keyword.merge([path: path_from_output_path(output_path)])

    metadata = contents
    |> Extractor.extract_metadata
    |> Keyword.merge(metadata)

    Map.put(index, :metadata, metadata)
  end
end
