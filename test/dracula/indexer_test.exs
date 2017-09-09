defmodule Dracula.IndexerTest do
  use ExUnit.Case
  alias Dracula.Indexer

  test "indexes a directory" do
    assert Indexer.index("test/single_file") == %{
      "index.html" => %{ contents: "<!-- index.html -->\n", metadata: [] }
    }
  end

  test "indexes a directory with a markdown file" do
    assert Indexer.index("test/markdown_file") == %{
      "index.html" => %{ contents: "<!-- index.md -->", metadata: [] }
    }
  end

  test "indexes a directory with a layout file" do
    assert Indexer.index("test/file_with_layout") == %{
      "index.html" => %{
        contents: "<!-- layout -->\n<!-- index.html -->\n\n",
        metadata: []
      }
    }
  end

  test "indexes a directory with an EEx file" do
    assert Indexer.index("test/eex_file") == %{
      "index.html" => %{ contents: "<!-- index.eex -->\n", metadata: [] }
    }
  end

  test "indexes a directory with an EEx file and metadata" do
    assert Indexer.index("test/eex_file_with_metadata") == %{
      "index.html" => %{
        contents: "<!-- index.eex -->\n",
        metadata: [title: "index.eex"]
      }
    }
  end

  test "indexes a directory with a subdirectory" do
    assert Indexer.index("test/subdirectory") == %{
      "index.html" => %{
        contents: "<!-- index.html -->\n",
        metadata: []
      },
      "sub/index.html" => %{
        contents: "<!-- sub/index.html -->\n",
        metadata: []
      }
    }
  end
end
