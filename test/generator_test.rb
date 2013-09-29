require File.expand_path('../test_helper', __FILE__)
require 'dracula/generator'
require 'dracula/resource'

def root_path
  File.expand_path('source', File.dirname(__FILE__))
end

describe Dracula::Generator, "concerning finding pages and resources" do
  before do
    @generator = Dracula::Generator.new(File.expand_path('source', File.dirname(__FILE__)))
    pages = @generator.pages

    @paths = pages.map do |page| 
      page.instance_variable_get(:'@source_path').to_s 
    end
  end

  it "finds all pages" do
    @paths.should.include File.join(root_path, 'index.markdown')
    @paths.should.include File.join(root_path, 'about/index.html.erb')
    @paths.should.include File.join(root_path, '_articles/2013/article/index.markdown')
    @paths.should.include File.join(root_path, 'style.css')
  end

  it "finds special resources" do
    resources = @generator.resources

    resource = resources['articles'].first
    path = resource.instance_variable_get(:'@source_path').to_s

    path.should == File.join(root_path, '_articles/2013/article/index.markdown')
  end

  it "does not include directories" do
    @paths.should.not.include File.join(root_path, 'articles')
    @paths.should.not.include File.join(root_path, 'about')
  end

  it "does not include underscored files" do
    @paths.should.not.include File.join(root_path, '_layout.html.erb')
  end
end
