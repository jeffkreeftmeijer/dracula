defmodule Dracula.IndexerTest do
  use ExUnit.Case
  alias Dracula.Indexer

  test "indexes a directory" do
    assert Indexer.index("test/single_file") == %{
      "index.html" => %{
        contents: "<!-- index.html -->\n",
        metadata: [path: "/"]
      }
    }
  end

  test "ignores _output directories" do
    assert Indexer.index("test/with_output_directory") == %{
      "index.html" => %{
        contents: "<!-- index.html -->\n",
        metadata: [path: "/"]
      }
    }
  end

  test "indexes a directory with a markdown file" do
    assert Indexer.index("test/markdown_file") == %{
      "index.html" => %{
        contents: "<!-- index.md -->",
        metadata: [path: "/"]
      }
    }
  end

  test "indexes a directory with a layout file" do
    assert Indexer.index("test/file_with_layout") == %{
      "index.html" => %{
        contents: "<!-- layout -->\n<!-- index.html -->\n\n",
        metadata: [path: "/"]
      }
    }
  end

  test "indexes a directory with an EEx file" do
    assert Indexer.index("test/eex_file") == %{
      "index.html" => %{
        contents: "<!-- index.eex -->\n",
        metadata: [path: "/"]
      }
    }
  end

  test "indexes a directory with an EEx file and metadata" do
    assert Indexer.index("test/eex_file_with_metadata") == %{
      "index.html" => %{
        contents: "<!-- index.eex -->\n",
        metadata: [title: "index.eex", path: "/"]
      }
    }
  end

  test "indexes a directory with a subdirectory" do
    assert Indexer.index("test/subdirectory") == %{
      "index.html" => %{
        contents: "<!-- index.html -->\n",
        metadata: [path: "/"]
      },
      "sub/index.html" => %{
        contents: "<!-- sub/index.html -->\n",
        metadata: [path: "/sub/"]
      }
    }
  end

  test "indexes a directory with a subdirectory and multiple layouts" do
    assert Indexer.index("test/sub_layouts") == %{
      "index.html" => %{
        contents: "<!-- _layout.eex -->\n<!-- index.html -->\n\n",
        metadata: [path: "/"]
      },
      "sub/index.html" => %{
        contents: "<!-- _layout.eex -->\n<!-- sub/_layout.eex -->\n<!-- sub/index.html -->\n\n\n",
        metadata: [path: "/sub/"]
      }
    }
  end

  test "indexes a file with extractable metadata" do
    assert Indexer.index("test/extractable_metadata") == %{
      "index.html" => %{
        contents: "<a id=\"indexhtml\"></a><h1>index.html</h1>\n",
        metadata: [title: "index.html", path: "/"]
      }
    }
  end
end
