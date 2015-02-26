Rails.application.routes.draw do
  root 'welcome#index'

  get 'welcome/about', as: 'about'
  get 'welcome/off_campus_login', as: 'off_campus_login'

  post 'contact_us' => 'contact_us#create', as: :contact_us
  get  'contact_us' => 'contact_us#new',    as: :contact_us_form

  blacklight_for :catalog
  get 'lib/:id' => 'catalog#show',
    constraints: { id: /ark:\/99999\/fk4\w{7}/ }

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  mount Riiif::Engine => '/images'
  mount Qa::Engine => '/qa'

  mount HydraEditor::Engine => '/'

  mount Hydra::Collections::Engine => '/'

  get 'collections', to: 'collections#index', as: 'collection_index'

end
