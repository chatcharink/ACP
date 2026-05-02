Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "front#home"
  get "/switch_lang", to: "application#switch_lang"
  post "/registrations", to: "registrations#create"
  get "/registrations/search", to: "registrations#search"
  post "/registrations/:id/upload_slip", to: "registrations#update_slip"
  get "/registrations/:id/certificate", to: "registrations#download_certificate"
  get "/registrations/:id/comment", to: "registrations#download_comment"

  namespace :backend do
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    get "dashboard", to: "dashboard#index"
    resources :registrations do
      member do
        patch :approve
        patch :reject
        patch :approve_song
        patch :reject_song
        get :receipt
      end
    end

    resources :competitions do
      member do
        get :score_pdf
        get :certificate
        get :admin_edit
        patch :admin_update
        get :comment_template
      end

      collection do
        get :bulk_certificate
        get :bulk_comment
      end
    end
    
    resource :settings, only: [:show, :update]
    resources :users
  end
  
end
