defmodule Dracula.IndexerTest do
  use ExUnit.Case
  alias Dracula.Indexer

  test "indexes a directory" do
    assert Indexer.index("test/single_file") == %{
      "index.html" => %{
        contents: "<!-- index.html -->\n",
        input_path: "test/single_file/index.html",
        layouts: []
      }
    }
  end

  test "indexes a directory with a layout file" do
    assert Indexer.index("test/file_with_layout") == %{
      "index.html" => %{
        contents: "<!-- layout -->\n<!-- index.html -->\n\n",
        input_path: "test/file_with_layout/index.html",
        layouts: ["<!-- layout -->\n<%= @contents %>\n"]
      }
    }
  end
end
