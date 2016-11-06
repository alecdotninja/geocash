Rails.application.routes.draw do
<<<<<<< HEAD

  get 'home/index'

  resources :geocashes do
=======
  resources :geocashes, param: :description, only: [:index] do
>>>>>>> 4e8e7b0f517dc96065381c90d5a05c303c57a90e
    member do
      get :simulate
    end
  end

  resources :accounts, only: [:show] do
    resources :transfers, only: [:create, :update]
  end
end
