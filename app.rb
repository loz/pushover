require 'sinatra'

get '/' do
  "Deployed Successfully<br/><tt>#{env.inspect}</tt>"
end
