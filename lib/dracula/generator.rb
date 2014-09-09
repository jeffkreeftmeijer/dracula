require 'pathname'
require 'yaml'

module Dracula
  class Generator
    def initialize(root_path)
      @root_path = Pathname.new(root_path)
    end

    def find_pages_and_resources
      @pages = []
      @resources = {}

      paths = Rake::FileList["#{@root_path}/**/*"]

      if File.exists?(gitignore = "#{@root_path}/.gitignore")
        ignore = File.read(gitignore).split
        paths.exclude(*ignore.map { |path| "#{@root_path}/#{path}" })
      end

      paths.each do |path|
        path = Pathname(path)

        if File.file?(path) && File.basename(path) !~ /^_/ 
          resource = Resource.new(path, @root_path) 
          @pages << resource

          if resource.type
            @resources[resource.type] ||= []
            @resources[resource.type] << resource
          end
        end
      end
    end

    def pages
      find_pages_and_resources unless @pages
      @pages
    end

    def resources
      find_pages_and_resources unless @resources
      @resources
    end

    def generate
      pages.each do |resource|
        puts resource.instance_variable_get(:@source_path)

        resource.data = resources.merge({:current => resource})

        FileUtils.mkdir_p(resource.output_directory)

        File.open(resource.output_path, 'w') do |file|
          file.write(resource.content)
        end
      end
    end
  end
end
