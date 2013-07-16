require 'stripmem/web'
require 'stripmem/websocket'

module StripMem
  class App
    def self.run!(argv)
      new.run!
    end

    def run!
      processes = { $$ => '(server)' }
      start_time = Time.now
      EventMachine.run do
        channel = EM::Channel.new
        EM::PeriodicTimer.new(0.2) do
          ps = `ps -o pid=,rss= -p #{processes.keys.join(',')}`.lines.each_with_object({}) { |line, h| pid, rss = line.split(/\s+/) ; h[pid.to_i] = rss.to_i }
          offset = Time.now - start_time
          channel.push :offset => offset, :samples => processes.map { |pid, name| { :name => "[#{pid}] #{name}", :rss => ps[pid] } }
        end
        WebSocket.new(channel).run!
        Thread.new do
          Web.new(channel).run! # This doesn't return until sinatra exits. (Sinatra handles SIGINT.)
          EM.stop
        end
      end
    end
  end
end
