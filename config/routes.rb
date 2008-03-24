ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dashboard', :action => 'index'

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.resources :users do |user|
    user.resources :matches
  end
  map.resources :sessions
  
  map.forgot_password 'forgot_password', :controller => 'users', :action => 'forgot_password'
  map.token_login 'token_login/:token', :controller => 'sessions', :action => 'token_login'
  
  map.resources :matches do |match|
    match.resources :comments
  end
  map.resources :teams
  
  map.resources :logs
  
  map.resources :accounts
  
  map.connect 'p/:action', :controller => 'pages'
  map.public_root 'p', :controller => 'pages', :action => 'index'
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end