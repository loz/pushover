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

  def input_headers
    Hash[env.select {|k,v| k.starts_with? 'HTTP_'}.map do |k,v|
      name = k.gsub(/^HTTP_/, '').split('_').map {|p| p.downcase.camelize}.join('-')
      [name , v]
    end]
  end


  def save_message(uid, method)
    data = {
      :method => method,
      :headers => input_headers
    }
    case method
    when :post
      data[:body] = request.body.read.dup
    else
      data[:query] = request.query_string.dup
    end
    @endpoint = Endpoint.find_by_uid(uid)
    @endpoint.messages.create data
    ''
  end

  get '/' do
    erb :welcome
    [200, {'Access-Control-Allow-Origin' => '*'}, erb(:welcome)]
  end


  get '/new' do
    require_user!
    endpoint = current_user.endpoints.create
    ref = endpoint.uid
    redirect '/endpoints/%s/view' % ref
  end

  get '/endpoints/:uid' do |uid|
    save_message(uid, :get)
  end

  post '/endpoints/:uid' do |uid|
    save_message(uid, :post)
  end

  get '/endpoints/:uid/view' do |uid|
    require_user!
    @endpoint = current_user.endpoints.find_by_uid(uid)
    erb :endpoint
  end

  get '/auth/github/callback' do
    auth = env['omniauth.auth']
    user = User.find_by_uid(auth.uid.to_s)
    unless user
      user = User.create :uid => auth.uid.to_s, :name => auth.info.nickname
    end
    session[:userid] = user.id
    redirect '/'
  end
end
