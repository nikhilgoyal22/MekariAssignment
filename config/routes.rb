Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :policies
  resources :companies
  resources :employees do
    get 'file_upload', on: :collection
    post 'upload', on: :collection
  end

  root to: "employees#file_upload"
end
