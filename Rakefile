require 'rake/testtask'

task :default => :test

desc "Run all tests"
task :test do
  Rake::TestTask.new do |t|
    t.test_files = FileList["test/**/*_test.rb"]
    t.verbose = true
  end
end
