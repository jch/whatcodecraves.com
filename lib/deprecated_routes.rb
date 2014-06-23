# The old url structure was one of the following
#
# * `/articles/YYYY/MM/DD/some_underscore_title/` with trailing slash or without
# * `/articles/YYYY/MM/DD/some_underscore_title/index.html` hardcoded index.html
#
# This middleware normalizes these routes to permanently redirect to
# the canonical permalink format.
#
# @see Post
class DeprecatedRoutes
  def initialize(app)
    @app = app
  end

  def call(env)
    request    = Rack::Request.new(env)
    normalized = normalized_path(request.path)
    if request.path == normalized
      @app.call(env)
    else
      uri = URI.parse(request.url).tap {|u| u.path = normalized}
      [301, {'Location' => uri.to_s}, []]
    end
  end

  def normalized_path(path)
    if path == '/archives'
      '/posts'
    elsif path.index('/articles') == 0
      Post.new(path.gsub('/articles', '/posts')).permalink
    else
      path
    end
  end
end
