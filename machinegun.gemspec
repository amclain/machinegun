version = File.read(File.expand_path('../version', __FILE__)).strip

Gem::Specification.new do |s|
  s.name      = 'machinegun'
  s.version   = version
  s.date      = Time.now.strftime '%Y-%m-%d'
  s.summary   = 'An automatic reloading webserver for Ruby.'
  s.description = "An automatic reloading webserver for Ruby."
  
  s.homepage  = 'https://github.com/amclain/machinegun'
  s.authors   = ['Alex McLain']
  s.email     = ['alex@alexmclain.com']
  s.license   = 'MIT'
  
  s.files     =
    ['license.txt', 'README.md'] +
    # Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['doc/**/*']
  
  s.executables = [
  ]
  
  # s.required_ruby_version = '>= 2.0.0'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rb-readline'
  s.add_development_dependency 'rspec', '~>3.1.0'
  s.add_development_dependency 'rspec-its', '~> 1.0.1'
  s.add_development_dependency 'fivemat'
end
