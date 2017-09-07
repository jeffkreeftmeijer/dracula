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
    |> Path.join("*.html")
    |> Path.wildcard
    |> Enum.map(fn(path) ->
      index(path, Path.relative_to(path, root))
    end)
    |> Enum.into(%{})
  end

  defp index(input_path, output_path) do
    index = %{input_path: input_path}
    |> fetch_layout
    |> fetch_contents

    {output_path, index}
  end

  defp fetch_contents(%{input_path: input_path, layouts: layouts} = index) do
    contents = input_path
    |> File.read!
    |> Renderer.render(input_path, layouts)

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
end
