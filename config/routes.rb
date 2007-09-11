ActionController::Routing::Routes.draw do |map|
  map.resources :users, :sessions
  
  map.dashboard 'd/:action', :controller => 'dashboard'
  
  map.resources :games
  map.resources :people
  
  map.activate 'activate/:activation_code', :controller => 'users', :action => 'activate'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.home '', :controller => 'dashboard', :action => 'index'
end