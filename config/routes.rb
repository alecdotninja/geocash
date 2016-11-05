Rails.application.routes.draw do
  resources :geocashes do
    member do
      get :simulate
    end
  end

  resources :accounts, only: [:show] do
    resources :transfers, only: [:create, :update]
  end
end
