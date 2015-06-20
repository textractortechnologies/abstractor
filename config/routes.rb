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
    end
    member do
      put :clear
    end
    resources :abstractor_suggestions
  end

  resources :abstractor_abstraction_schemas do
  end
end