ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dashboard', :action => 'index'

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.open_id_complete         'sessions/open_id', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_complete_on_user 'users/open_id',    :controller => "users",    :action => "create", :requirements => { :method => :get }
  map.resources :users do |user|
    user.resources :user_openids
    user.resources :games
  end
  map.resources :sessions
  
  map.dashboard 'd/:action', :controller => 'dashboard'
  map.resources :games
  map.resources :teams
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end