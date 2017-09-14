defmodule Dracula.ExtractorTest do
  use ExUnit.Case
  alias Dracula.Extractor

  test "extracts the header" do
    assert Extractor.extract_metadata("# title")[:title] == "title"
    assert Extractor.extract_metadata("# title\n nope")[:title] == "title"
    assert Extractor.extract_metadata("## nope\n# title")[:title] == "title"
    assert Extractor.extract_metadata("nope")[:title] == nil
  end
end
