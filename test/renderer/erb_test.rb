require File.expand_path('../../test_helper', __FILE__)
require 'dracula/renderer/erb'

describe Dracula::Renderer::ERB do
  it "renders ERB" do
    Dracula::Renderer::ERB.render("<%= %w(foo bar baz).join(',') %>").should == "foo,bar,baz"
  end

  it "uses passed variables" do
    Dracula::Renderer::ERB.render('<%= @foo %>', :foo => 'bar').should == 'bar'
  end
end
