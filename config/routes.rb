Rails.application.routes.draw do
  resources :geocashes do
    member do
      get :simulate
    end
  end

  resources :transfers, only: [:show, :new, :create, :edit, :update]
end
