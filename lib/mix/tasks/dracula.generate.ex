defmodule Mix.Tasks.Dracula.Generate do
  @moduledoc """
  Generates static sites.
  """

  alias Dracula.Indexer

  @doc """
  Generates a static site, and stores the results in _output.
  """
  def run(path) do
    path
    |> Indexer.index
    |> Enum.each(&generate/1)
  end

  defp generate({filename, %{contents: contents}}) do
    output_path = "_output/#{filename}"

    output_path
    |> Path.dirname
    |> File.mkdir_p!

    File.write!("_output/#{filename}", contents)
  end
end
