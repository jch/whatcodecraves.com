Blog::Application.routes.draw do
  match '/articles'    => 'posts#index', as: :posts
  match '/articles*id' => 'posts#show',  as: :post, format: false

  root to: 'home#index'
end