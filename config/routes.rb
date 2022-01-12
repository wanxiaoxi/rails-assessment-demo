Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'events/delete_all', to: 'events#destroy_all'
      resources :events do
        get 'comments/delete_all', to: 'comments#destroy_all'
        resources :comments
      end
    end
  end
end
