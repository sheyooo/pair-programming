$LOAD_PATH << '.'

require 'rack'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/base'
require 'sinatra/flash'
require 'firebase'
require 'json'
require 'uri'
require 'digest'
require 'lib/pairpro/pair_pro'
require 'sinatra/reloader' if development?

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  # set :port, 80

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
    @url_base = 'http://localhost:9292/'
  end

  before /\/$|\/new_session|\/sessions|\/session\/*/ do
    redirect to('/login') if session[:username].nil?
  end

  get '/' do
    @list_co_sessions = []
    unless @app.list_sessions(session[:username]).nil?
      @list_co_sessions = @app.list_sessions(session[:username])
    end
    erb :index, layout: :layout
  end

  get '/login' do
    erb :login, layout: :layout
  end

  post '/login' do
    if @app.login(params['username'], params['password'])
      session[:username] = params['username']
      flash.next['alert alert-success animated flash'] = "Welcome #{session[:username]}, you are wise!"
      redirect to('/')
    else
      flash['alert alert-error animated flash'] = 'Wrong username or password!'
      redirect to('/login')
    end
  end

  get '/signup' do
    erb :signup, layout: :layout
  end

  post '/signup' do
    if (valid? params['username']) && (valid? params['email']) && (valid? params['password'])
      if @app.signup(params['username'], params['email'], params['password'])
        session[:username] = params['username']
        flash.next['alert alert-success animated flash'] = "Welcome #{session[:username]}, you are wise!"
        redirect to('/')
      else
        flash['alert alert-error animated flash'] = 'We have that account| Try another username'
        redirect to('/login')
      end
    else
      flash['alert alert-error animated flash'] = 'Please fill in all fields!'
      redirect to('/login')
    end
  end

  get '/session/:id' do
    @id = params['id']
    erb :session, layout: :layout
  end

  get '/sessions' do
    erb :sessions, layout: :layout
  end

  get '/new_session' do
    erb :new_session, layout: :layout
  end

  post '/new_session' do
    params['id'] = URI.escape(params['id'])
    if @app.new_coding_session(params['id'], session[:username])
      text = "You have just created a new session, to pair up, just share this urls <a href='#{@url_base}session/#{params['id']}'></a>"
      flash.next['alert alert-success animated flash'] = text
      redirect to "/session/#{params['id']}"
    else
      flash['alert alert-error animated flash'] = 'Conflict try another ID'
      redirect to '/new_session'
    end
  end

  get '/delete_session/:id' do
    params['id'] = URI.escape(params['id'])
    @app.delete_session(params['id'], session[:username])
    redirect to '/'
  end

  get '/logout' do
    flash.next['alert alert-warning animated flash'] = "Bye, #{session[:username]}, hope to see you again!."
    session[:username] = nil
    redirect to('/')
  end

  # run! if app_file == $0
end
