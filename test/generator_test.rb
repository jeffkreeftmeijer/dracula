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

    @paths = resources.map do |resource|
      resource.instance_variable_get(:'@source_path').to_s
    end
  end

  it "finds all resources" do
    @paths.should.include File.join(root_path, 'index.markdown')
    @paths.should.include File.join(root_path, 'about/index.html.erb')
    @paths.should.include File.join(root_path, 'articles/2013/article.markdown')
  end

  it "does not include directories" do
    @paths.should.not.include File.join(root_path, 'about')
    @paths.should.not.include File.join(root_path, 'articles')
  end

  it "does not include underscored files" do
    @paths.should.not.include File.join(root_path, '_config.yml')
  end

  it "does not include files in underscored directories" do
    @paths.should.not.include File.join(root_path, '_ignore/index.html')
  end
end
