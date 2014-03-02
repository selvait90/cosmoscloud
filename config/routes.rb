Cosmoscloud::Application.routes.draw do

  # user authentication 
  get "sign_up" => "users#new", :as =>  "sign_up"
  get "log_in" => "sessions#new", :as =>  "log_in"
  get "log_out" => "sessions#destroy", :as =>  "log_out"
  root :to => "sessions#new"
  get "dashboard" => "cosmoses#list"
  resources :users
  resources :sessions
  get 'oauth2callback' => 'cosmoses#set_google_drive_token' # user return to this after login
  
  # google drive routes
  #get 'oauth2callback' => 'documents#set_google_drive_token' # user return to this after login
  #get 'list_google_doc'  => 'documents#list_google_docs', :as => :list_google_doc #for listing the 
  #get 'list_drive'  => 'documents#list_drive', :as => :list_drive #for listing the 
  #get 'download_google_doc'  => 'documents#download_google_docs', :as => :download_google_doc #download
  
  #get 'oauth2callback' => 'cosmoses#set_google_drive_token' # user return to this after login
  #get 'list_google_doc'  => 'cosmoses#list_google_docs', :as => :list_google_doc #for listing the 
  #get 'download_google_doc'  => 'cosmoses#download_google_docs', :as => :download_google_doc #download
  #get 'drivelist' => 'cosmoses#get_drive_client', :as => :drivelist
  # dropbox routes
  #get  "cosmoses/main"
  get  "cosmoses/list"
  post "cosmoses/upload"
  get  "cosmoses/auth_start"
  get  "cosmoses/auth_finish"

  #get  "dropbox/main"
  #get  "dropbox/list"
  #post "dropbox/upload"
  #get  "dropbox/auth_start"
  #get  "dropbox/auth_finish"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
