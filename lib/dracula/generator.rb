require 'pathname'
require 'yaml'

module Dracula
  class Generator
    def initialize(root_path)
      @root_path = Pathname.new(root_path)
    end

    def resources
      unless @resources
        @resources = {}

        Dir["#{@root_path}/**/*"].each do |path|
          path = Pathname(path)

          if File.file?(path) && File.basename(path) !~ /^_/ 
            resource = Resource.new(path, @root_path) 
            @resources[resource.type] ||= []
            @resources[resource.type] << resource
          end
        end
      end

      @resources
    end

    def generate
      resources.values.flatten.each do |resource|
        resource.data = {:resources => resources}

        FileUtils.mkdir_p(resource.output_directory)

        File.open(resource.output_path, 'w') do |file|
          file.write(resource.content)
        end
      end
    end
  end
end
