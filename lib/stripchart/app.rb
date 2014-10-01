require 'stripchart/web'
require 'stripchart/websocket'

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

module StripChart
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
      @timers = []
      EventMachine.run do
        data_channel = EM::Channel.new
        @timers = [
          EM::PeriodicTimer.new(0.2) { pump_fh(data_channel) },
        ]
        WebSocket.new(data_channel).run!
        Thread.new do
          puts "Starting web server"
          Web.new(data_channel).run! # This doesn't return until sinatra exits. (Sinatra handles SIGINT.)
          puts "Exit..."
          EM.stop
          exit
        end
      end
    end

    def pump_fh(data_channel, fh=$stdin)
      offset = Time.now - start_time
      samples = [
        { :name => "random", :value => rand },
      ]
      data_channel.push :offset => offset, :samples => samples
    end
  end
end
