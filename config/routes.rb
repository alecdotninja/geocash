Rails.application.routes.draw do
  resources :geocashes, param: :description, only: [:index] do
    member do
      get :simulate
    end
  end

  resources :accounts, only: [:show] do
    resources :transfers, only: [:create, :update]
  end
end
