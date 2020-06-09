# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout 'login'
  before_filter :domain_required
  before_filter :must_be_admin, only: [:impersonate]
  before_filter :must_be_impersonating, only: [:unimpersonate]

  def new; end

  def create
    password_authentication(params[:login], params[:password])
  end

  def update
    unless params[:current_game].blank? || params[:current_game][:id].blank?
      redirect_to new_game_url and return if params[:current_game][:id] == 'new'
      self.current_game = current_account.games.find(params[:current_game][:id])
      self.current_user.update_attribute :last_game, self.current_game unless impersonating?
    end
    redirect_back_or_default('/')
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = 'You have been logged out.'
    redirect_back_or_default('/')
  end

  def token_login
    user = User.find_by_login_token(params[:token])
    if user.blank?
      flash[:error] = 'The link you tried to use is either wrong or has already been used.'
      redirect_to login_url
    else
      self.current_user = user
      user.update_attribute :login_token, nil
      flash[:notice] =
        'You have logged in using a one time login. Please change your password to something you can remember.'
      redirect_to edit_user_url(user)
    end
  end

  def impersonate
    session[:real_user_id] ||= current_user.id
    session[:current_game_id] = nil
    user = User.find(params[:id])
    unless user.nil?
      self.current_user = user
      flash[:notice] = "Impersonating #{user.name} from #{user.account.name}"
      redirect_to root_url
    end
  end

  def unimpersonate
    self.current_user = User.find(session[:real_user_id])
    session[:real_user_id] = nil
    session[:current_game_id] = nil
    flash[:notice] = 'You are now yourself!'
    redirect_to root_url
  end

  private

  def password_authentication(login, password)
    self.current_user = current_account.users.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == '1'
        self.current_user.remember_me
        cookies[:auth_token] = {
          value: self.current_user.remember_token, expires: self.current_user.remember_token_expires_at
        }
      end
      successful_login
    else
      failed_login('Invalid login or password')
    end
  end

  def successful_login
    self.current_game = current_user.last_game unless current_user.last_game.nil?
    redirect_to root_url
  end

  def failed_login(message)
    flash[:error] = message
    redirect_to login_url
  end
end
