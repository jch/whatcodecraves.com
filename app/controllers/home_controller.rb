class HomeController < ApplicationController
  # Homepage
  def index
    @posts = Post.recent(6)
    fresh_when last_modified: Post.last_modified, public: true
  end

  # Sitemap
  #
  # Generated with [sitemap_generator](https://github.com/kjvarga/sitemap_generator)
  # with results written to Rails.cache
  def sitemap
    fresh_when last_modified: Post.last_modified, public: true

    links    = [posts_path, changefreq: 'daily', priority: 0.6, lastmod: Post.last_modified]
    Post.all.each do |post|
      links << [post.permalink, lastmod: post.updated_at, priority: 0.33]
    end

    sitemap = Sitemap.new({
      base_url: base_url,
      compress: false,
      store:    Rails.cache,
      links:    links
    })

    xml = sitemap.fetch(request.path.gsub('/', ''), {
      base_url: base_url,
      links:    links
    })

    if sitemap
      sitemap.ping!
      render xml: xml
    else
      head :missing
    end
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