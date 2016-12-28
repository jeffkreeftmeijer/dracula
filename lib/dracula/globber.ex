defmodule Dracula.Globber do
  @doc ~S"""
  Globs all files in the given `root` into a list of tuples which contain:

  * the file's directory path (relative from the root path), in a split list.
  * the file's path (relative to the current working directory).
  * the file's contents.

  ## Examples

  With a single file, `glob/1` returns a list with a single tuple. Since this
  file is in the root path, the directory path list in the tuple is empty.

    iex> Dracula.Globber.glob("test/fixtures/single_file")
    {:ok, [{
      [],
      "test/fixtures/single_file/index.html",
      "<!-- single_file/index.html -->\n"
    }]}

  When the file is in a subdirectory, the directory list in the tuple holds the
  directory's name.

    iex> Dracula.Globber.glob("test/fixtures/file_in_subdirectory")
    {:ok, [{
      ["sub"],
      "test/fixtures/file_in_subdirectory/sub/index.html",
      "<!-- file_in_subdirectory/sub/index.html -->\n"
    }]}
  """
  def glob(root) do
    {:ok, glob(root, root)}
  end

  defp glob(starting_path, root) do
    starting_path
    |> Path.join("*")
    |> Path.wildcard
    |> to_resources_from(root)
  end

  defp to_resources_from([], _root), do: []
  defp to_resources_from([head|tail], root) do
    case File.dir?(head) do
      true ->
        glob(head, root) ++ to_resources_from(tail, root)
      false -> [
        {subdirectory_split_from(head, root), head, File.read!(head)}
        |to_resources_from(tail, root)
      ]
    end
  end

  defp subdirectory_split_from(path, root) do
    relative_path = path
    |> Path.dirname
    |> Path.relative_to(root)

    case relative_path == root do
      false -> relative_path |> Path.split
      true -> []
    end
  end
end
