Rails.application.routes.draw do
  
  get 'keyboard' => "kakao#keyboard"
  post "message" => "kakao#message"
  
  delete "chat_room/:user_key" => "kakao#chat_room"
  delete "friend/:user_key" => "kakao#friend_del"
  post   "friend/:user_key" => "kakao#friend_add"
  
  get '/dkdkdlwkddlqslek' => 'savedb#loginpage'
  get '/dkdkdlwkd/dlqslek_country' => 'savedb#savecountry'
  get '/dkdkdlwkd/dlqslek_game' => 'savedb#makegamelist'
  
  post '/dkdkdlwkd/dlqslek_des' => 'savedb#destroy_db'
  
  get 'db/check_pw' => 'savedb#check_pw'
  get 'db/loginpage' => 'savedb#loginpage'
  get 'db/mainpage' => 'savedb#mainpage'
  get 'db/destroypage' => 'savedb#destroypage'
  # get 'db/saveemd' => 'savedb#saveemd'
  # get 'db/savegsg' => 'savedb#savegsg'
  # get 'db/savesido' => 'savedb#savesido'

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
