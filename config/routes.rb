Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/"). Landing on the sign-in form makes sense since every
  # other route requires being logged in (see ApplicationController#require_login).
  root "sessions#new"

  # Sign-up: separate GET (show the form) and POST (submit it) routes, both handled by
  # RegistrationsController, which is exempt from the login requirement.
  get "signup" => "registrations#new"
  post "signup" => "registrations#create"

  # Sign-in/out: handled by SessionsController, also exempt from the login requirement.
  get "login" => "sessions#new"
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy"

  # Categories are intentionally limited to index/new/create: there's no per-category show/
  # edit/delete UI (see README "Known Limitations" for why deletion isn't implemented).
  resources :categories, only: [ :index, :new, :create ]
  # Tasks get the full RESTful set: index, new, create, show, edit, update, destroy.
  resources :tasks
end
