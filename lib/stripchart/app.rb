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
        EM::PeriodicTimer.new(0.2) { pump_fh(data_channel) }
        WebSocket.new(data_channel).run!
        Thread.new do
          puts "Reading data from stdin..."
          Web.new(data_channel).run! # This doesn't return until sinatra exits. (Sinatra handles SIGINT.)
          puts "Exit..."
          EM.stop
          exit
        end
      end
    end

    def pump_fh(data_channel, fh=$stdin)
      @buffer ||= ""
      data = @buffer + fh.read_nonblock(100_000)
      samples = {}
      data.lines.each do |line|
        if line.end_with?("\n")
          if line =~ /^(.*\S)\s+([\d.]+)$/
            samples[$1] = $2.to_f
          end
        else
          # This should be the last, partial line.
          @buffer = line
        end
      end

      offset = Time.now - start_time
      samples = samples.map { |name,value| { :name => name, :value => value } }

      data_channel.push :offset => offset, :samples => samples

    rescue EOFError
      EM.stop

    rescue IO::WaitReadable
      # nothing to read
    end
  end
end
