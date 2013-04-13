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
      @resources ||= []
    end

    def generate
      Dir["#{@root_path}/**/*"].each do |path|
        if File.file?(path) && File.basename(path) !~ /^_/
          resources << Resource.new(path, @root_path, @config) 
        end
      end

      resources.each do |resource|
        FileUtils.mkdir_p(resource.output_directory)

        File.open(resource.output_path, 'w') do |file|
          file.write(resource.content)
        end
      end
    end
  end
end
