ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dashboard', :action => 'index'

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.resources :games do |games|
    games.resources :matches do |matches|
      matches.resources :comments
    end
    
    games.resources :teams
  
    games.resources :logs
    
    games.resources :users do |user|
      user.resources :matches
    end
  end

  map.resources :users
  map.resources :sessions, :member => { :impersonate => :put }, :collection => { :unimpersonate => :put }
  
  map.forgot_password 'forgot_password', :controller => 'users', :action => 'forgot_password'
  map.token_login 'token_login/:token', :controller => 'sessions', :action => 'token_login'
  
  map.resources :accounts
  
  map.connect 'p/:action', :controller => 'pages'
  map.public_root 'p', :controller => 'pages', :action => 'index'
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end