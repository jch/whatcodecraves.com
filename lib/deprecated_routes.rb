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
    if env['PATH_INFO'] == (path = normalized_path(env['PATH_INFO']))
      @app.call(env)
    else
      [301, {'Location' => path}, []]
    end
  end

  def normalized_path(path)
    if path.index('/articles') == 0
      Post.article_permalink(path)
    else
      path
    end
  end
end