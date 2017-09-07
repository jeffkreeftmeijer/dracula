defmodule Dracula.RendererTest do
  use ExUnit.Case
  alias Dracula.Renderer

  test "renders a plain HTML page" do
    assert Renderer.render("<!-- index.html -->\n", "index.html") ==
      "<!-- index.html -->\n"
  end

  test "renders an HTML page with a layout" do
    assert Renderer.render(
      "<!-- index.html -->\n",
      "index.html",
      ["<!-- _layout.eex -->\n<%= @contents %>"]
    ) == "<!-- _layout.eex -->\n<!-- index.html -->\n"
  end
end

