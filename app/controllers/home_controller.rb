class HomeController < ApplicationController
  # Homepage
  def index
    @posts = Post.recent(6)
    fresh_when last_modified: Post.last_modified, public: true
  end

  # 404 Not found page
  def not_found
    response.status = 404
  end

  def robots
    robots = <<-ROBOTS
Sitemap: #{URI.join(base_url, 'sitemap_index.xml.gz')}
ROBOTS
    render text: robots, content_type: 'text/plain'
  end
end