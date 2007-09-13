ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'dashboard', :action => 'index'

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.open_id_complete         'sessions', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_complete_on_user 'users',    :controller => "users",    :action => "create", :requirements => { :method => :get }
  map.resources :users do |user|
    user.resources :user_openids
  end
  map.resource  :sessions
  
  map.dashboard 'd/:action', :controller => 'dashboard'
  map.resources :games
  map.resources :people
  map.resources :teams
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end