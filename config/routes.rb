ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dashboard', :action => 'index'

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.resources :users do |user|
    user.resources :games
  end
  map.resources :sessions
  
  map.resources :games do |game|
    game.resources :comments
  end
  map.resources :teams
  
  map.resources :accounts
  
  map.connect 'p/:action', :controller => 'pages'
  map.public_root 'p', :controller => 'pages', :action => 'index'
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end