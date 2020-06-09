ScoreKeeper::Application.routes.draw do
  root to: 'dashboard#index'
  match 'signup' => 'users#new', as: :signup
  match 'login' => 'sessions#new', as: :login
  match 'logout' => 'sessions#destroy', as: :logout
  resources :games do
    resources :matches do
      resources :comments
    end

    resources :teams
    resources :logs
    resources :users do
      resources :matches
    end

    resources :comparisons
  end

  resources :users
  resources :sessions do
    collection do
      put :unimpersonate
    end
    member do
      put :impersonate
    end
  end

  match 'forgot_password' => 'users#forgot_password', as: :forgot_password
  match 'token_login/:token' => 'sessions#token_login', as: :token_login
  resources :accounts
  match 'p/:action' => 'pages#index'
  match 'p' => 'pages#index', as: :public_root
  match '/:controller(/:action(/:id))'
end
