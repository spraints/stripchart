require 'em-websocket'
require 'json'

module StripMem
  class WebSocket
    def initialize(channel)
      @channel = channel
      @data = []
      @channel.subscribe { |msg| @data << msg }
    end

    def run!
      EventMachine::WebSocket.start(:host => 'localhost', :port => 9998) do |ws|
        ws.onopen do
          @data.each { |msg| ws.send(JSON.generate(msg)) }
          sid = @channel.subscribe { |msg| ws.send(JSON.generate(msg)) }
          ws.onclose { @channel.unsubscribe(sid) }
        end
      end
    end
  end
end
