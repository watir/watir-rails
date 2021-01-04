Dummy::Application.routes.draw do
  resources :tests, only: :index do
    get :raise_error, on: :collection
  end
end
