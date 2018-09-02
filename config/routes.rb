Rails.application.routes.draw do
  resources :short_urls
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'short_urls/upload_csv_urls', to: 'short_urls#upload_csv_urls'
end
