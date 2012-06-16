require 'config/environment'
require 'sinatra/base'
require 'omniauth'
require 'omniauth-github'

class App < Sinatra::Application
  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :github, ENV['GH_TOKEN'], ENV['GH_SECRET']
  end

  get '/' do
    if session[:userid]
      ''
      #erb :welcome
    else
      erb :welcome
    end
  end

  get '/auth/github/callback' do
    auth = env['omniauth.auth']
    user = User.find_by_uid(auth.uid)
    unless user
      user = User.create :uid => auth.uid, :name => auth.info.nickname
    end
    session[:userid] = user.id
  end
end
