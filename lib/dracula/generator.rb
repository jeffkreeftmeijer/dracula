require 'pathname'

module Dracula
  class Generator
    def initialize(root_path)
      @root_path = Pathname.new(root_path)
    end

    def resources
      @resources ||= []
    end

    def generate
      Dir["#{@root_path}/**/*"].each do |path|
        if File.file?(path) && File.basename(path) !~ /^_/
          resources << Resource.new(path, @root_path) 
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
