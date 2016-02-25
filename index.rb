$LOAD_PATH << "."

require 'rack'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/base'
require 'sinatra/flash'
require 'firebase'
require 'json'
require 'uri'
require 'digest'
require "lib/pairpro/pair_pro"
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
    @app = PairPro::PairProgram.new
    @url_base = "http://localhost:9292/"
  end

  before /\/$|\/new_session|\/sessions|\/session\/*/ do
    redirect to('/login') if session[:username].nil?
  end

  get '/' do
    @list_co_sessions = []
    if ! @app.list_sessions(session[:username]).nil?
      @list_co_sessions = @app.list_sessions(session[:username])
    end
    erb :index, :layout => :layout
  end

  get '/login' do
    erb :login, :layout => :layout
  end

  post '/login' do
    if @app.login(params['username'], params['password'])
      session[:username] = params['username']
      redirect to('/')
    else
      flash["alert alert-error"] = 'Wrong username or password!'
      redirect to('/login')
    end
  end

  get '/signup' do
    erb :signup, :layout => :layout
  end

  post '/signup' do

    if (valid? params['username']) && (valid? params['email']) && (valid? params['password'])
      if @app.signup(params['username'], params['email'], params['password'])
        session[:username] = params['username']
        redirect to('/')
      else
        flash["alert alert-error"] = 'We have that account| Try another username'
        redirect to('/login')
      end
    else
      flash["alert alert-error"] = 'Please fill in all fields!'
      redirect to('/login')
    end
  end

  get '/session/:id' do
    @id = params["id"]
    erb :session, :layout => :layout
  end

  get '/sessions' do
    erb :sessions, :layout => :layout
  end

  get '/new_session' do
    erb :new_session, :layout => :layout
  end

  post '/new_session' do
    params["id"] = URI.escape(params["id"])
    if @app.new_coding_session(params["id"], session[:username])
      redirect to "/session/#{params['id']}"
    else
      flash["alert alert-danger"] = "Conflict try another ID"
      redirect to "/new_session"
    end
  end

  get '/delete_session/:id' do
    params["id"] = URI.escape(params["id"])
    @app.delete_session(params["id"], session[:username])
    redirect to "/"
  end

  get '/logout' do
    session[:username] = nil
    redirect to('/')
  end

end
