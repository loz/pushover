require 'sinatra'

get '/' do
  "Deployed Successfully<br/><tt>#{settings.environment}</tt>"
end
