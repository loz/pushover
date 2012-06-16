require 'config/environment'
require 'sinatra/base'
require 'omniauth'
require 'omniauth-github'

class App < Sinatra::Application
  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :github, ENV['GH_TOKEN'], ENV['GH_SECRET']
  end

  def current_user
    @current_user ||= User.find_by_id(session[:userid])
  end


  def require_user!
    redirect '/' unless current_user
  end

  get '/' do
    erb :welcome
  end


  get '/new' do
    require_user!
    endpoint = current_user.endpoints.create
    ref = endpoint.uid
    redirect '/endpoints/%s/view' % ref
  end

  get '/endpoints/:uid/view' do |uid|
    require_user!
    @endpoint = current_user.endpoints.find_by_uid(uid)
    erb :endpoint
  end

  get '/auth/github/callback' do
    auth = env['omniauth.auth']
    user = User.find_by_uid(auth.uid)
    unless user
      user = User.create :uid => auth.uid, :name => auth.info.nickname
    end
    session[:userid] = user.id
    redirect '/'
  end
end
