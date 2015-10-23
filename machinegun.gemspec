version = File.read(File.expand_path('../version', __FILE__)).strip

Gem::Specification.new do |s|
  s.name      = 'machinegun'
  s.version   = version
  s.date      = Time.now.strftime '%Y-%m-%d'
  s.summary   = 'An automatic reloading Rack development web server for Ruby.'
  s.description = 'An automatic reloading Rack development web server for Ruby.'
  
  s.homepage  = 'https://github.com/amclain/machinegun'
  s.authors   = ['Alex McLain']
  s.email     = ['alex@alexmclain.com']
  s.license   = 'MIT'
  
  s.files     = [
      'license.txt',
      'README.md',
    ] +
    Dir[
      'bin/**/*',
      'lib/**/*',
      'doc/**/*',
    ]
  
  s.executables = ['machinegun']
  
  s.add_dependency 'rack', '~> 1.6', '>= 1.6.4'
  s.add_dependency 'filewatcher', '~> 0.5.2'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rb-readline'
  s.add_development_dependency 'rspec', '~>3.1.0'
  s.add_development_dependency 'rspec-its', '~> 1.0.1'
  s.add_development_dependency 'fivemat'
end
