Blog::Application.routes.draw do
  match '/posts*id' => 'posts#show', as: :post, format: false
  resources :posts, :only => :index

  match '/rss.xml'        => 'posts#index',  as: :rss, format: 'xml'
  match '/robots.txt'     => 'home#robots',  as: :robots

  if Rails.env.test?
    # raises an error for testing 500's
    match '/error' => 'posts#error', as: :error
  end

  # Catch all renders 404 because rescue_from doesn't work
  match '*id' => 'home#not_found', format: false

  root to: 'home#index'
end
