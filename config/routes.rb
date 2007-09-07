ActionController::Routing::Routes.draw do |map|
  map.resources :users, :sessions
  
  map.dashboard 'd/:action', :controller => 'dashboard'
  
  map.resources :games
  map.resources :people
  
  map.connect '', :controller => 'dashboard', :action => 'index'
end