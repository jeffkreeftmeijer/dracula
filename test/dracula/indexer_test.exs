defmodule Dracula.IndexerTest do
  use ExUnit.Case
  alias Dracula.Indexer

  test "indexes a directory" do
    assert Indexer.index("test/single_file") == %{
      "index.html" => %{contents: "<!-- index.html -->\n"}
    }
  end
end
