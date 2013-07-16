require 'sinatra/base'

module StripMem
  class Web
    def initialize(channel)
      @channel = channel
    end

    def run!
      App.run!(:port => 9999, :server => 'webrick')
    end
    
    class App < Sinatra::Base
      get '/' do
        erb :index
      end
    end
  end
end
