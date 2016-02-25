require 'rack'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/base'
require 'sinatra/flash'
require 'firebase'
require 'json'
require 'uri'
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
    @list_co_sessions = []
    if !list_sessions(session[:username]).nil?
      @list_co_sessions = list_sessions(session[:username])
    end
    erb :index, :layout => :layout
  end

  get '/login' do
    erb :login, :layout => :layout
  end

  post '/login' do
    if login(params['username'], params['password'])
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
      response = @firebase.get("users/#{params['username']}", shalow: true)
      puts response.body
      if response.body.nil?
        @firebase.push("users/#{params['username']}", username: params['username'],
                                                      email: params['email'],
                                                      password: params['password'])
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
    if new_coding_session(params["id"])
      @firebase.push("users/#{session[:username]}/sessions", {session_id: params['id']})
      redirect to "/session/#{params['id']}"
    else
      flash["alert alert-danger"] = "Conflict try another ID"
      redirect to "/new_session"
    end
  end

  get '/delete_session/:id' do
    params["id"] = URI.escape(params["id"])
    delete_session(params["id"])
    redirect to "/"
  end

  get '/logout' do
    session[:username] = nil
    redirect to('/')
  end

  def login(u, p)
    auth = false
    if (valid? u) && (valid? p)
      response = @firebase.get("users/#{params['username']}")
      print res = response.body.to_a[0]

      if res[1].to_h["password"] == params["password"]
        auth = true
      end      
    end

    auth
  end

  def new_coding_session(id)
    response = @firebase.get("/sessions/#{id}")
    res = response.body

    if res == nil
      true
    else
      false
    end    
  end

  def coding_session(id)

  end

  def list_sessions(username)
    response = @firebase.get("users/#{username}/sessions")
    res = response.body
  end

  def delete_session(id)
    @firebase.delete("/sessions/#{id}/")
    @firebase.delete("/users/#{session['username']}/sessions/", {session_id: "#{id}"})
  end


end
