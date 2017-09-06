defmodule Dracula.Indexer do
  @moduledoc """
  Indexes source directories.
  """

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
    {output_path, %{contents: File.read!(input_path)}}
  end
end
