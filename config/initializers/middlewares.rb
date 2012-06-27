Blog::Application.configure do |config|
  config.middleware.use DeprecatedRoutes
end