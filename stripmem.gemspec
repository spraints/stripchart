require File.expand_path('lib/stripmem/version', File.dirname(__FILE__))
Gem::Specification.new do |s|
  s.name    = 'stripmem'
  s.version = StripMem::VERSION
  s.summary = s.description = 'Stripchart memory usage'
  s.homepage = 'https://github.com/spraints/stripmem'
  s.authors = ["Matt Burke"]
  s.email   = 'spraints@gmail.com'
  s.files   = Dir['lib/**/*', 'README.md']
  s.bindir  = 'exe'
  s.executables = %w(
    stripmem
  )
  s.add_dependency 'em-websocket'
  s.add_dependency 'sinatra'
  s.add_development_dependency 'debugger'
end
