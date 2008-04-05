class UsersController < ApplicationController
  before_filter :domain_required
  before_filter :login_required, :except => [ :forgot_password ]
  before_filter :must_be_account_admin_or_self, :only => [ :edit, :update ]
  
  filter_parameter_logging :password
  
  def index
    @user = current_account.users.build
    render :layout => false if iphone_user_agent?
  end
  
  def show
    @time_period = params[:period] ? params[:period].to_i : 30
    @user = current_account.users.find(params[:id])
    @all_time_high = @user.all_time_high
    @all_time_low = @user.all_time_low
    @matches_per_day = @user.memberships.count(:group => 'matches.played_on', :limit => 10, :order => 'matches.played_on DESC', :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')
    render :layout => false if iphone_user_agent?
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
    @users = current_account.users.find(:all, :order => 'login')
    render :action => 'index'
  end
  
  def edit
    @user = current_account.users.find(params[:id])
  end
  
  def update
    @user = current_account.users.find(params[:id])
    mugshot = Mugshot.create(params[:mugshot])
    @user.mugshot = mugshot unless mugshot.nil? || mugshot.size.nil?
    @user.is_account_admin = params[:user][:is_account_admin] if (current_user.is_account_admin? || current_user.is_admin?) && !params[:user][:is_account_admin].nil?
    @user.is_admin = params[:user][:is_admin] if current_user.is_admin? && !params[:user][:is_admin].nil?
    @user.enabled = params[:user][:enabled] if (current_user.is_account_admin? || current_user.is_admin?) && !params[:user][:enabled].nil?
    @success = @user.update_attributes(params[:user])
    respond_to do |format|
      if @success
        flash[:notice] = "User saved successfully."
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
  
  def forgot_password
    if params[:username] || params[:email]
      user = current_account.users.find_by_login(params[:username]) if params[:username]
      user ||= current_account.users.find_by_email(params[:email]) if params[:email]
      
      unless user.blank?
        flash[:notice] = 'You should receive an email containing a one-time login link shortly.'
        user.set_login_token
        UserNotifier.deliver_forgot_password(user)
        redirect_to login_url
        return
      else
        flash.now[:error] = 'No user was found with the specified username or e-mail.'
      end
    end
    render :layout => 'login'
  end
  
  protected
  def must_be_account_admin_or_self
    redirect_to root_url unless current_user.id.to_s == params[:id] || current_user.is_account_admin? || current_user.is_admin?
  end
  
  def must_be_admin_or_self
    redirect_to root_url unless current_user.id.to_s == params[:id] || current_user.is_admin?
  end
end