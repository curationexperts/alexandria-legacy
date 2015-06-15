Rails.application.routes.draw do
  root 'welcome#index'

  get 'welcome/about', as: 'about'

  post 'contact_us' => 'contact_us#create', as: :contact_us
  get  'contact_us' => 'contact_us#new',    as: :contact_us_form

  blacklight_for :catalog
  get 'lib/:id' => 'catalog#show',
    constraints: { id: /ark:\/99999\/fk4\w{7}/ }

  resources :local_authorities, only: :index

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
  mount Riiif::Engine => '/images'
  mount Qa::Engine => '/qa'
  mount HydraEditor::Engine => '/'
  mount Hydra::Collections::Engine => '/'
end
