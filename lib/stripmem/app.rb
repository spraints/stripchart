require 'stripmem/web'
require 'stripmem/websocket'

if RUBY_VERSION =~ /^1.8/
  module Enumerable
    def each_with_object(obj)
      each do |x|
        yield x, obj
      end
      obj
    end
  end
end

module StripMem
  class App
    def self.run!(argv)
      new(argv).run!
    end

    def initialize(argv)
      @command = argv
      @start_time = Time.now
    end

    attr_reader :command, :start_time

    def run!
      EventMachine.run do
        spawn!
        channel = EM::Channel.new
        EM::PeriodicTimer.new(1.0) { find_children }
        EM::PeriodicTimer.new(0.2) { ps(channel) }
        WebSocket.new(channel).run!
        Thread.new do
          Web.new(channel).run! # This doesn't return until sinatra exits. (Sinatra handles SIGINT.)
          kill!
          EM.stop
          exit
        end
      end
      kill!
    end

    def kill!
      Process.kill('QUIT', @child.to_i)
    rescue => e
      puts "kill #{@child.inspect}: #{e}"
    end

    def find_children
      children = `ps a -o ppid=,pid=,command=`.lines.each_with_object(Hash.new { |h,k| h[k] = [] }) { |line, h| (line =~ /(\d+) +(\d+) +(.*)/) && h[$1].push(:pid => $2, :name => $3) }
      parents = processes.keys
      while parent = parents.shift
        children[parent.to_s].each do |child|
          if child[:name] !~ /^ps /
            pid = child[:pid].to_i
            parents << pid
            processes[pid] ||= child[:name]
          end
        end
      end
    end

    def ps(channel)
      ps = `ps -o pid=,rss= -p #{processes.keys.join(',')}`.lines.each_with_object({}) { |line, h| pid, rss = line.split(/\s+/) ; h[pid.to_i] = rss.to_i }
      offset = Time.now - start_time
      channel.push :offset => offset, :samples => processes.map { |pid, name| { :name => "[#{pid}] #{name}", :rss => ps[pid] } }
    end

    def processes
      @processes ||= { $$ => '(stripmem)' }
    end

    def spawn!
      @child = fork do
        exec(*command)
      end
      processes[@child] = command.join(' ')
    end
  end
end
