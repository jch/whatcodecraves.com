Blog::Application.configure do |config|
  config.middleware.use Rack::Rewrite do
    r301 '/sitemap.xml.gz', '/sitemap_index.xml.gz'
  end
  config.middleware.use DeprecatedRoutes
end