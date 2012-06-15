require 'sinatra'

get '/' do
  "Deployed Successfully<br/><pre>#{env.inscpect}</pre>"
end
