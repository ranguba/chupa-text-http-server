Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resource :extraction, only: [:show, :create]

  root to: redirect("/extractions")
end
