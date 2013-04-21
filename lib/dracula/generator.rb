require 'pathname'
require 'yaml'

module Dracula
  class Generator
    def initialize(root_path)
      @root_path = Pathname.new(root_path)

      config_path = File.join(@root_path, '_config.yml')

      if File.exist? config_path
        @config = YAML.load_file(config_path)
      else
        @config = {}
      end
    end

    def resources
      unless @resources
        @resources = {}

        Dir["#{@root_path}/**/*"].each do |path|
          path = Pathname(path)

          if File.file?(path) && File.basename(path) !~ /^_/ && path.relative_path_from(@root_path).to_s !~ /^_/
            resource = Resource.new(path, @root_path, @config) 
            @resources[resource.type] ||= []
            @resources[resource.type] << resource
          end
        end
      end

      @resources
    end

    def generate
      resources.values.flatten.each do |resource|
        resource.binding = binding

        FileUtils.mkdir_p(resource.output_directory)

        File.open(resource.output_path, 'w') do |file|
          file.write(resource.content)
        end
      end
    end
  end
end
