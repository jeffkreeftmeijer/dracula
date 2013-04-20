require File.expand_path('../test_helper', __FILE__)
require 'dracula/generator'
require 'dracula/resource'

describe Dracula::Generator do
  it "finds all resources" do
    generator = Dracula::Generator.new(File.expand_path('source', File.dirname(__FILE__)))
    resources = generator.resources

    paths = resources.map do |resource|
      resource.instance_variable_get(:'@source_path').to_s
    end

    root_path = File.expand_path('source', File.dirname(__FILE__))
    paths.should.include File.join(root_path, 'index.markdown')
    paths.should.include File.join(root_path, 'about/index.html.erb')
    paths.should.include File.join(root_path, 'articles/2013/article.markdown')
  end
end
