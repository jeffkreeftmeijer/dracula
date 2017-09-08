defmodule Dracula.Indexer do
  @moduledoc """
  Indexes source directories.
  """
  alias Dracula.Renderer

  @doc """
  Indexes a directory.
  """
  def index(root) do
    root
    |> Path.join("*.{html,md,eex}")
    |> Path.wildcard
    |> Enum.reject(fn(path) ->
      path
      |> Path.basename
      |> String.starts_with?("_")
    end)
    |> Enum.map(fn(path) ->
      index(path, Path.relative_to(path, root))
    end)
    |> Enum.into(%{})
  end

  defp index(path, relative_path) do
    index = %{input_path: path}
    |> fetch_layout
    |> fetch_metadata
    |> render_contents
    |> Map.drop([:layouts, :input_path, :metadata])

    {output_path_from_relative_path(relative_path), index}
  end

  defp output_path_from_relative_path(path) do
    case Path.extname(path) do
      ".md" -> String.replace_trailing(path, ".md", ".html")
      ".eex" -> String.replace_trailing(path, ".eex", ".html")
      _ -> path
    end
  end

  defp render_contents(%{input_path: input_path, layouts: layouts, metadata: metadata} = index) do
    contents = input_path
    |> File.read!
    |> Renderer.render(Path.extname(input_path), metadata, layouts)
Map.put(index, :contents, contents)
  end

  defp fetch_layout(%{input_path: input_path} = index) do
    layouts = case input_path
    |> Path.dirname
    |> Path.join("_layout.eex")
    |> File.read do
      {:ok, layout} -> [layout]
      _ -> []
    end

    Map.put(index, :layouts, layouts)
  end

  defp fetch_metadata(%{input_path: input_path} = index) do
    metadata = case input_path
    |> Path.dirname
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

    Map.put(index, :metadata, metadata)
  end
end
