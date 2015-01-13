Rails.application.routes.draw do

  root 'welcome#index'

  get 'welcome/about', as: 'about'
  get 'welcome/off_campus_login', as: 'off_campus_login'

  blacklight_for :catalog
  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'


  mount Riiif::Engine => '/images'
  mount HydraEditor::Engine => '/'

  mount Hydra::Collections::Engine => '/'

end
