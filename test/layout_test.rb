require File.expand_path('../test_helper', __FILE__)
require 'dracula/layout'


describe Dracula::Layout do
  before do
    @path = File.expand_path('source/_layout.html.erb', File.dirname(__FILE__))
  end

  it 'renders content with a layout file' do
    layout = Dracula::Layout.new(@path)
    result = layout.render { 'foo' }
    result.should.include '<h1>Header</h1>'
    result.should.include 'foo'
  end

  it "uses passed variables" do
    layout = Dracula::Layout.new(@path, {:foo => 'bar'})
    layout.render { '@foo' }.should.include 'bar'
  end
end
