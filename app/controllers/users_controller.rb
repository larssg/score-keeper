class UsersController < ApplicationController
  before_filter :domain_required
  before_filter :login_required
  before_filter :must_be_account_admin, :only => [ :index ]
  before_filter :must_be_account_admin_or_self, :only => [ :edit, :update ]
  
  def index
    @users = current_account.users.find(:all, :order => 'login')
    @user = current_account.users.build
  end
  
  def show
    @time_period = params[:period] ? params[:period].to_i : 30
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
    @user.mugshot = mugshot unless mugshot.nil? || mugshot.size.nil? || !(mugshot.size > 0)

    if current_user.is_admin? && params[:user][:is_admin]
      @user.is_admin = true
    end

    @user.save!

    flash[:notice] = 'User created successfully'
    redirect_to users_path
  rescue ActiveRecord::RecordInvalid
    @users = User.find(:all, :order => 'login')
    render :action => 'index'
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
        format.html { redirect_to users_url }
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
  def must_be_account_admin
    return current_user.is_account_admin? || current_user.is_admin?
  end
  
  def must_be_admin
    return current_user.is_admin?
  end
  
  def must_be_account_admin_or_self
    return current_user.id.to_s == params[:id] || current_user.is_account_admin? || current_user.is_admin?
  end
  
  def must_be_admin_or_self
    return current_user.id.to_s == params[:id] || current_user.is_admin?
  end
end