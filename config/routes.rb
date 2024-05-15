require 'sidekiq/web'
Rails.application.routes.draw do
  resources :imports do
    collection do
      post :run
    end
  end
  resources :insales
  devise_for :users
  resources :products do
    resources :variants do
      collection do
        post :run
        post :upload # if variant new
        post :delete_image
      end
      resources :images do
        collection do
          post :upload # if we have variant
        end
      end
      member do
        patch :sort_image
      end
    end
    collection do
      post :run
      post :load_variants
      get :load_xml_data
    end
    member do
      get :load_variants_images
      # get :load_variants
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "products#index"

  # Mount Sidekiq web interface at a specific route
  mount Sidekiq::Web => '/sidekiq'
  
end
