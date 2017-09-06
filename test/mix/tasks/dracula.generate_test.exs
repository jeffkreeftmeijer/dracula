defmodule Mix.Tasks.Dracula.Generate.Test do
  use ExUnit.Case
  alias Mix.Tasks.Dracula.Generate

  test "generates a static site" do
    Generate.run(["test/single_file"])
    assert File.read!("_output/index.html") == "<!-- index.html -->\n"
  end
end
