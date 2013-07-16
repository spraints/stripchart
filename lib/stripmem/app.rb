require 'stripmem/web'
require 'stripmem/websocket'

module StripMem
  class App
    def self.run!(argv)
      new.run!
    end

    def run!
      EventMachine.run do
        channel = EM::Channel.new
        WebSocket.new(channel).run!
        Web.new(channel).run!
      end
    end
  end
end
