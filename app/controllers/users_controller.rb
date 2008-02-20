class UsersController < ApplicationController
  before_filter :login_required, :only => [ :index, :edit, :update, :change_password ]
  before_filter :must_be_admin, :only => [ :index ]
  before_filter :must_be_admin_or_self, :only => [ :edit, :update ]
  
  def index
    @users = current_account.users.find(:all, :order => 'login')
    @user = current_account.users.build
  end
  
  def show
    @user = current_account.users.find(params[:id])
    @all_time_high = @user.all_time_high
    @all_time_low = @user.all_time_low
  end
  
  def new
    @user = User.new(params[:user])
    @user.account = current_account
    @user.valid? if params[:user]
    
    render :layout => 'public'
  end
  
  def create
    @user = User.new(params[:user])
    @user.account = current_account

    mugshot = Mugshot.create(params[:mugshot])
    @user.mugshot = mugshot unless mugshot.nil? || !(mugshot.size > 0)

    if logged_in? && current_user.is_admin? && params[:user][:is_admin]
      @user.is_admin = true
    end

    @user.save!

    if logged_in?
      flash[:notice] = 'User created successfully'
      redirect_to users_path
    else
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    end
  rescue ActiveRecord::RecordInvalid
    if logged_in?
      @users = User.find(:all, :order => 'login')
      render :action => 'index'
    else
      render :action => 'new', :layout => 'public'
    end
  end
  
  def edit
    @user = current_account.users.find(params[:id])
  end
  
  def update
    @user = current_account.users.find(params[:id])
    mugshot = Mugshot.create(params[:mugshot])
    @user.mugshot = mugshot unless mugshot.nil? || mugshot.size.nil?
    @user.is_admin = params[:user][:is_admin] if current_user.is_admin?
    @success = @user.update_attributes(params[:user])
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
    @user = current_account.users.find(params[:id])
    if @user.destroy
      if @user.id == current_user
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session
        flash[:notice] = "You have removed your account."
        redirect_back_or_default('/')
      else
        flash[:notice] = 'User deleted.'
        redirect_to users_path
      end
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