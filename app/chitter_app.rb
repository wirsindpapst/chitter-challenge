ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
require_relative 'data_mapper_setup'
require_relative 'helpers'

class ChitterApp < Sinatra::Base

  use Rack::MethodOverride
  register Sinatra::Flash
  enable :sessions
  set :session_secret, 'super secret'

  get '/' do
    @peeps = Peep.all.reverse
    erb :'landing_page'
  end

  get '/users/register' do
    @user = User.new
    erb :'users/register'
  end

  get '/sessions/sign_in' do
    erb :'sessions/sign_in'
  end

  post '/users/new_user_authenticate' do
    @user = User.create(first_name: params[:first_name],
                        last_name: params[:last_name],
                        username: params[:username],
                        email: params[:email],
                        password: params[:password],
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect '/peeps/peepdeck'
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'/users/register'
    end
  end

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/peeps/peepdeck'
    else
      flash.now[:errors] = ['The email or password is incorrect']
      erb :'sessions/sign_in'
    end
  end

  get '/peeps/peepdeck' do
    @peeps = Peep.all.reverse
    erb :'peeps/peepdeck'
  end

  post '/peeps/peepdeck' do
    new_peep = Peep.create(peep_text: params[:peep], user_id: current_user.id)
    redirect 'peeps/peepdeck'
  end

  delete '/sessions/sign_out' do
    session[:user_id] = nil
    flash.keep[:notice] = 'Peep again soon'
    redirect to '/'
  end

  helpers Helpers

  # start the server if ruby file executed directly
  run! if app_file == $0
end
