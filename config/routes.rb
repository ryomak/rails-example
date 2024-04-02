Rails.application.routes.draw do
  get 'rag_queries/new'
  get 'rag_queries/create'
  get 'search_queries/new'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :articles

  resources :rag_queries, only: [:index] do
    collection do
      post :search
    end
  end

end
