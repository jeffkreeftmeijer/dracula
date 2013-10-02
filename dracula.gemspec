Gem::Specification.new do |spec|
  spec.name     = 'dracula'
  spec.version  = '0.1.0'

  spec.summary  = "A simple static site generator that doesn't only do technical blogs." 

  spec.author   = 'Jeff Kreeftmeijer'
  spec.email    = 'jeff@kreeftmeijer.com'
  spec.homepage = 'http://github.com/jeffkreeftmeijer/dracula'

  spec.files    = Dir.glob("{lib}/**/*") + %w(README.markdown)

  spec.add_development_dependency('rake')
  spec.add_development_dependency('peck', '~> 0.5.0')

  spec.add_runtime_dependency('pygments.rb', '~> 0.4.2')
  spec.add_runtime_dependency('redcarpet', '~> 2.2.2')
end
