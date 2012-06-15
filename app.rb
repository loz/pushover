require 'config/environment'
require 'sinatra'

class App < Sinatra::Application
  get '/' do
    erb :welcome
  end
end
