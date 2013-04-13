require File.expand_path('../test_helper', __FILE__)
require 'dracula/resource'

def root_path
  File.expand_path('source', File.dirname(__FILE__))
end

def index_resource
  Dracula::Resource.new(File.join(root_path, 'index.markdown'), root_path)
end

def about_resource
  Dracula::Resource.new(File.join(root_path, 'about/index.markdown'), root_path)
end

def stylesheet_resource
  Dracula::Resource.new(File.join(root_path, 'style.css'), root_path)
end

describe Dracula::Resource, 'concerning paths' do
  it "has an output directory" do
    about_resource.output_directory.should == File.join(root_path, '_output/about')
  end

  it "has an output directory in the ouput root" do
    index_resource.output_directory.should == File.join(root_path, '_output')
  end

  it "has an output path with an html extension for markdown files" do
    about_resource.output_path.to_s.should == File.join(root_path, '_output/about/index.html')
  end

  it "has an output path for files that don't need formatting" do
    stylesheet_resource.output_path.to_s.should == File.join(root_path, '_output/style.css')
  end
end

describe Dracula::Resource, 'concerning content' do
  it "has raw content" do
    index_resource.raw_content.should == "## Welcome\n"
  end

  it "has content with layouts" do
    index_resource.content.should.include 'Header'
  end

  it "uses Markdown formatting" do
    index_resource.content.should.include '<h2>Welcome</h2>'
  end

  it "doesn't use Markdown formatting on non Markdown files" do
    stylesheet_resource.content.should.not.include '<p>'
  end
end

describe Dracula::Resource, 'concerning layouts' do
  it "has a layout" do
    index_resource.layouts.map(&:path).should == [File.join(root_path, '_layout.html.erb')]
  end

  it "has multiple layouts" do
    about_resource.layouts.map(&:path).should == [
      File.join(root_path, 'about/_layout.html.erb'),
      File.join(root_path, '_layout.html.erb')
    ]
  end
end
