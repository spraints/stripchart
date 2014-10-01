require File.expand_path('lib/stripchart/version', File.dirname(__FILE__))
Gem::Specification.new do |s|
  s.name    = 'stripchart'
  s.version = StripChart::VERSION
  s.summary = s.description = 'Stripchart anything'
  s.homepage = 'https://github.com/spraints/stripchart'
  s.authors = ["Matt Burke"]
  s.email   = 'spraints@gmail.com'
  s.license = 'MIT'
  s.files   = Dir['lib/**/*', 'README.md', 'LICENSE']
  s.bindir  = 'exe'
  s.executables = %w(
    stripchart
  )
  s.add_dependency 'em-websocket'
  s.add_dependency 'json'
  s.add_dependency 'sinatra'
  s.add_development_dependency 'debugger'
end
