require File.expand_path('../test_helper', __FILE__)
require 'dracula/renderer'

describe Dracula::Renderer do
  it "renders Markdown" do
    Dracula::Renderer.render('foo *bar* **baz**').should == "<p>foo <em>bar</em> <strong>baz</strong></p>\n"
  end

  it "highlights embedded code blocks" do
    Dracula::Renderer.render("```ruby\nbar\n```").should == "<pre><div class=\"highlight\">\n<pre><span class=\"n\">bar</span>\n</pre>\n</div>\n</pre>\n"
  end
end
