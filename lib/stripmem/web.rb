require 'sinatra/base'

module StripMem
  class Web
    def initialize(channel)
      @channel = channel
    end

    def run!
      App.run!
    end
    
    class App < Sinatra::Base
      get '/' do
        haml :index
      end
    end
  end
end
