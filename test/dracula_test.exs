defmodule DraculaTest do
  use ExUnit.Case
  doctest Dracula

  test "greets the world" do
    assert Dracula.hello() == :world
  end
end
