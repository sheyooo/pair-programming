require 'rack'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/base'
require 'sinatra/flash'
require 'firebase'
require 'json'
require './lib/pairpro/pair_pro'
require 'sinatra/reloader' if development?

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  enable :sessions
  register Sinatra::Flash

  helpers do
    def valid?(str)
      str.strip!
      if str.length > 0
        return true
      else
        false
      end
    end
  end

  before do
    base_uri = 'https://pair-pro.firebaseio.com/'
    @firebase = Firebase::Client.new(base_uri)
  end

  before '/' do
    redirect to('/login') if session[:username].nil?
  end

  get '/' do
    erb :index, layout: :layout
  end

  get '/login' do
    erb :login, layout: :layout
  end

  post '/login' do
    if login(params['username'], params['password'])
      session[:username] = params['username']
      redirect to('/')
    else
      flash[:error] = 'Wrong username or password!'
      redirect to('/login')
    end
  end

  get '/signup' do
    erb :signup, layout: :layout
  end

  post '/signup' do
    if (valid? params['username']) && (valid? params['email']) && (valid? params['password'])
      response = @firebase.get("users/#{params['username']}", shalow: true)
      puts response.body
      if response.body.nil?
        @firebase.push("users/#{params['username']}", username: params['username'],
                                                      email: params['email'],
                                                      password: params['password'])
        session[:username] = params['username']
        redirect to('/')
      else
        flash[:error] = 'We have that account| Try another username'
        redirect to('/login')
      end
    else
      flash[:error] = 'Please fill in all fields!'
      redirect to('/login')
    end
  end

  get '/sessions' do
    erb :sessions, layout: :layout
  end

  get '/logout' do
    session[:username] = nil
    redirect to('/')
  end

  def login(u, p)
    auth = false
    if (valid? u) && (valid? p)
      response = @firebase.get("users/#{params['username']}")
      puts res = response.body

      res.each do |_k, v|
        return false if v['password'].nil?

        auth = true if v['password'] == params['password']
      end
    end

    auth
  end
end
