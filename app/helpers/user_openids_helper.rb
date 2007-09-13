module UserOpenidsHelper

  def create
    if using_open_id?
      open_id_authentication
    else
      normal_create
    end
  end
  
  def normal_create
    throw "Implement me in this controller!"
  end

  # Pass optional :required and :optional keys to specify what sreg fields you want.
  # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
  # REMEMBER: a "required" field is not guaranteed to be returned by OpenID provider
  def open_id_authentication
    authenticate_with_open_id(params[:openid_url], 
        :required => [ :nickname ],
        :optional => [ :email, :fullname ]) do |result, identity_url, registration|
      if result.successful?
        successful_openid_login(identity_url, registration)
      else
        failed_login(result.message || "Sorry could not log in with identity URL: #{identity_url}")
      end
    end
  end


  private
    def successful_openid_login(identity_url, registration = {})
      unless @complete = (@user = User.find_by_identity_url(identity_url))
        @user = User.new(:identity_url => identity_url)
        assign_registration_attributes(identity_url, registration)
      end
      self.current_user = @user
      @complete ? 
        successful_login :
        unfinished_registration(identity_url)
    end
    
    # registration is a hash containing the valid sreg keys given above
    # use this to map them to fields of your user model
    def assign_registration_attributes(identity_url, registration)
      { 
        :login  => 'nickname', 
        :email  => 'email', 
        :name   => 'fullname' 
      }.each do |model_attribute, registration_attribute|
        unless registration[registration_attribute].blank?
          @user.send("#{model_attribute}=", registration[registration_attribute])
        end
      end
      #@user.login.gsub!(/\W+/,'').downcase unless @user.login.blank?
      @user.identity_url = identity_url
      @complete = @user.save
    end

    def successful_login
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    end

    def unfinished_registration(identity_url)
      params = {:user => @user.attributes.merge("identity_url" => identity_url)}
      redirect_to new_user_path(params)
      flash[:warning] = "Please complete registration"
    end
    
    def failed_login(message)
      flash.now[:error] = message
      render :action => 'new'
    end
end