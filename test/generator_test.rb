require File.expand_path('../test_helper', __FILE__)
require 'dracula/generator'
require 'dracula/resource'

def root_path
  File.expand_path('source', File.dirname(__FILE__))
end

describe Dracula::Generator, "concerning resources" do
  before do
    generator = Dracula::Generator.new(File.expand_path('source', File.dirname(__FILE__)))
    resources = generator.resources

    @paths = {}

    resources.each do |type, resources|
      @paths[type] = resources.map do |resource|
        resource.instance_variable_get(:'@source_path').to_s
      end
    end
  end

  it "finds all resources" do
    @paths[nil].should.include File.join(root_path, 'index.markdown')
    @paths['about'].should.include File.join(root_path, 'about/index.html.erb')
    @paths['articles'].should.include File.join(root_path, 'articles/2013/article/index.markdown')
  end

  it "does not include directories" do
    @paths[nil].should.not.include File.join(root_path, 'articles')
    @paths[nil].should.not.include File.join(root_path, 'about')
  end

  it "does not include underscored files" do
    @paths[nil].should.not.include File.join(root_path, '_config.yml')
  end

  it "does not include files in underscored directories" do
    @paths.should.not.has_key? '_ignore'
  end
end
