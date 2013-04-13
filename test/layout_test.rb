require File.expand_path('../test_helper', __FILE__)
require 'dracula/layout'

describe Dracula::Layout do
  it 'renders content with a layout file' do
    path = File.expand_path('source/_layout.html.erb', File.dirname(__FILE__))
    layout = Dracula::Layout.new(path)

    layout.render { 'foo' }.should == "<h1>Header</h1>\nfoo\n"
  end
end
