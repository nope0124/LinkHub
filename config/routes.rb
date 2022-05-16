Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root to: 'themes#index'
  get    '/search' => 'searches#search', as: 'search'
  # get    '/settings' => 'users/registrations#edit', as: 'edit_user'
  # patch  '/settings' => 'users#update', as: 'update_user'
  get    '/users/unsubscribe' => 'users#unsubscribe', as: 'unsubscribe'
  patch  '/users/withdrawal' => 'users#withdrawal', as: 'withdrawal'
  get    '/:user_name' => 'users#show', as: 'user'
  get    '/:user_name/themes/new' => 'themes#new', as: 'new_theme'
  post   '/:user_name' => 'themes#create', as: 'themes'
  get    '/:user_name/themes/:theme_hashid' => 'themes#show', as: 'theme'
  get    '/:user_name/themes/:theme_hashid/edit' => 'themes#edit', as: 'edit_theme'
  get    '/:user_name/themes/:theme_hashid/edit/new' => 'links#new', as: 'new_theme_link'
  post   '/:user_name/themes/:theme_hashid/edit' => 'links#create', as: 'theme_links'
  patch  '/:user_name/themes/:theme_hashid' => 'themes#update', as: 'update_theme'
  post   '/:user_name/themes/:theme_hashid/favorites' => 'favorites#create', as: 'theme_favorites'
  delete '/:user_name/themes/:theme_hashid/favorites' => 'favorites#destroy'
  get    '/:user_name/favorites' => 'favorites#index', as: 'user_favorites'
  post   '/:user_name/relationships' => 'relationships#create', as: 'user_relationships'
  delete '/:user_name/relationships' => 'relationships#destroy'
  get    '/:user_name/followings' => 'relationships#followings', as: 'user_followings'
  get    '/:user_name/followers' => 'relationships#followers', as: 'user_followers'
end
