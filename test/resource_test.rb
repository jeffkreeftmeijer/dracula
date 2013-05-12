require File.expand_path('../test_helper', __FILE__)
require 'dracula/resource'

def root_path
  File.expand_path('source', File.dirname(__FILE__))
end

def index_resource
  Dracula::Resource.new(File.join(root_path, 'index.markdown'), root_path)
end

def about_resource
  Dracula::Resource.new(File.join(root_path, 'about/index.html.erb'), root_path)
end

def article_resource
  Dracula::Resource.new(
    File.join(root_path, '_articles/2013/article/index.markdown'),
    root_path
  )
end

def stylesheet_resource
  Dracula::Resource.new(File.join(root_path, 'style.css'), root_path)
end

describe Dracula::Resource, 'concerning special resource types' do
  it "doesn't have a type" do
    about_resource.type.should.be.nil
  end

  it "has a type when in a resource directory" do
    article_resource.type.should == 'articles'
  end
end

describe Dracula::Resource, 'concerning paths' do
  it "has an output directory" do
    about_resource.output_directory.to_s.should == File.join(root_path, '_output/about')
  end

  it "has an output directory in the ouput root" do
    index_resource.output_directory.to_s.should == File.join(root_path, '_output')
  end

  it "has a output directory for special resources" do
    article_resource.output_directory.to_s.should == File.join(root_path, '_output/2013/article')
  end

  it "has an output path with an html extension for markdown files" do
    index_resource.output_path.to_s.should == File.join(root_path, '_output/index.html')
  end

  it "has an output path with an html extension for ERB files" do
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

  it "doesn't use layouts for non HTML output files" do
    stylesheet_resource.content.should.not.include 'Header'
  end

  it "uses Markdown formatting" do
    index_resource.content.should.include '<h2>Welcome</h2>'
  end

  it "renders ERB" do
    about_resource.content.should.include 'foo,bar'
  end

  it "uses passed variables" do
    resource = about_resource
    resource.data = {:foo => 'baz'}
    resource.content.should.include 'baz'
  end

  it "uses passed variables in layouts" do
    resource = article_resource
    resource.data = {:foo => 'baz'}
    resource.content.should.include 'baz'
  end

  it "doesn't do formatting for non Markdown or ERB files" do
    stylesheet_resource.content.should.not.include '<p>'
  end
end

describe Dracula::Resource, 'concerning layouts' do
  it "has a layout" do
    index_resource.layouts.map(&:path).should == [File.join(root_path, '_layout.html.erb')]
  end

  it "has multiple layouts" do
    article_resource.layouts.map(&:path).should == [
      File.join(root_path, '_articles/_layout.html.erb'),
      File.join(root_path, '_layout.html.erb')
    ]
  end

  it "doesn't have any layouts" do
    stylesheet_resource.layouts.should == []
  end
end

describe Dracula::Resource, 'concerning urls' do
  it "has an url" do
    about_resource.url.should == '/about'
  end

  it "has an url for the website index" do
    index_resource.url.should == '/'
  end

  it "has an url for rewritten paths" do
    article_resource.url.should == '/2013/article'
  end
end
