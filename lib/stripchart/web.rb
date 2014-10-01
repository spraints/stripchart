require 'sinatra/base'

module StripChart
  class Web
    def initialize(channel)
      @channel = channel
    end

    def run!
      puts "Starting a server on http://localhost:9999/"
      App.run!(:port => 9999, :server => 'webrick') do
        system "open http://localhost:9999/"
      end
    end
    
    class App < Sinatra::Base
      get '/' do
        erb :index, :locals => { :web_socket_url => "ws://localhost:9998/data" }
      end
    end
  end
end
