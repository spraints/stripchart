module StripMem
  class WebSocket
    def initialize(channel)
      @channel = channel
    end

    def run!
      EventMachine::WebSocket.start(:port => 9998) do |ws|
        ws.onopen do
          sid = @channel.subscribe { |msg| ws.send(msg) }
          ws.onclose { @channel.unsubscribe(sid) }
        end
      end
    end
  end
end
