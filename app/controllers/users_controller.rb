class UsersController < ApplicationController
  include UserOpenidsHelper
  
  before_filter :login_required, :only => [ :index, :edit, :update, :change_password ]
  before_filter :must_be_admin, :only => [ :index ]
  before_filter :must_be_admin_or_self, :only => [ :edit, :update ]
  
  def index
    @users = User.find(:all, :order => 'login')
  end
  
  def new
    @user = User.new(params[:user])
    @user.valid? if params[:user]
  end

  def normal_create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = User.find(params[:id])
    @user_openids = @user.user_openids
  end
  
  def update
    @user = User.find(params[:id])
    @success = @user.update_attributes(params[:user]) #TODO - protect some fields
    respond_to do |format|
      if @success
        flash[:notice] = "User account saved successfully."
        format.html { redirect_to :action => "edit" }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "You have been destroyed your account."
      redirect_back_or_default('/')
    else
      flash[:error] = "Unable to destroy account"
      render :action => 'edit'
    end
  end
    
  protected
  def must_be_admin
    return current_user.is_admin?
  end
  
  def must_be_admin_or_self
    return current_user.id.to_s == params[:id] || current_user.is_admin?
  end
end