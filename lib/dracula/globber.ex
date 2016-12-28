defmodule Dracula.Globber do
  @doc ~S"""
  Globs all files in the given `root` into a list of tuples which contain the
  file's directory path (relative from the root path) in a split list, and the
  filename (relative to the current working directory).

  ## Examples

  With a single file, `glob/1` returns a list with a single tuple. Since this
  file is in the root path, the list in the tuple is empty. The string in the
  tuple holds the relative path to the file, from the current working directory.

    iex> Dracula.Globber.glob("test/fixtures/single_file")
    {:ok, [{[], "test/fixtures/single_file/index.html"}]}
  """
  def glob(root) do
    resources = root
    |> Path.join("*")
    |> Path.wildcard
    |> to_resources_from(root)

    {:ok, resources}
  end

  defp to_resources_from([], _root), do: []
  defp to_resources_from([head|tail], root) do
    [{[], head}|to_resources_from(tail, root)]
  end
end
