Abstractor::Engine.routes.draw do
  resources :abstractor_abstraction_groups do
    member do
      put :update_wokflow_status
    end
  end

  resources :abstractor_abstractions do
    collection do
      put :update_all
      put :discard
      put :undiscard
      put :update_wokflow_status
    end
    member do
      put :clear
    end
    resources :abstractor_suggestions
  end

  resources :abstractor_abstraction_schemas, only: [:index, :show] do
    resources :abstractor_object_values
  end

  resources :abstractor_rules do
  end

  get '/abstractor_settings', controller: 'abstractor_settings', action: :index
end