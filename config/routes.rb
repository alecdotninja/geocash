Rails.application.routes.draw do
  resources :geocashes do
    member do
      get :simulate
    end
  end
end
