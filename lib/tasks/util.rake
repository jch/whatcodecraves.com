require 'util'

namespace :util do
  # Start webrick app server in a new thread. Server is killed after
  # the given block is evaluated. Access log is disabled, and error
  # messages are redirected to stdout.
  #
  # @param [Block] blk yielded server after start
  def start_server(&blk)
    thread = Thread.new {
      options = {
        Port:      8989 + rand(500),
        AccessLog: [],  # STFU webrick
        Logger:    Logger.new(STDOUT).tap {|l| l.level = Logger::WARN}
      }

      Rack::Handler::WEBrick.run(Blog::Application, options) do |server|
        [:INT, :TERM].each {|sig| trap(sig) {server.stop}}
        Thread.current[:server] = server
      end
    }
    sleep 1  # wait for server
    blk.call(thread[:server])
    thread[:server].stop
  end

  desc "Crawl the entire site for dead links"
  task crawl: :environment do
    require 'anemone'
    require 'anemone_extensions'
    start_server do |server|
      root = "http://127.0.0.1:#{server.config[:Port]}/"
      Anemone.crawl(root) do |spider|
        spider.on_every_page do |page|
          puts "#{page.code}: #{page.referer && page.referer.path || '/'} -> #{page.url.path}"
        end
      end
    end
  end

  # @see [sitemap_generator](https://github.com/kjvarga/sitemap_generator)
  desc "Write sitemap to public. Uses BASE_URL as anchor"
  task sitemap: :environment do
    include Blog::Application.routes.url_helpers

    link_set = SitemapGenerator::LinkSet.new({
      default_host: ENV['BASE_URL'],
      verbose:      true,
      include_root: false
    })

    link_set.add root_path, changefreq: 'always', priority: 0.8, lastmod: Post.last_modified
    link_set.add posts_path, changefreq: 'daily', priority: 0.6, lastmod: Post.last_modified
    Post.all.each do |post|
      link_set.add post.permalink, lastmod: post.updated_at, priority: 0.33
    end
    link_set.create
  end
end
