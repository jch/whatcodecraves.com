require 'uri'

# Wrapper object around SitemapGenerator. This class generates sitemaps
# from a list of links and writes the xml into an ActiveSupport compatible
# cache store.
#
# ## Example:
#
# ```ruby
# # Generates and writes sitemap_index.xml.gz and other sitemaps
# # to Rails.cache.
# sitemap = Sitemap.new({
#   base_url: base_url,
#   compress: false,
#   store:    Rails.cache,
#   links:    ['/path1', 'path2']
# })
#
# sitemap.fetch('sitemap_index.xml.gz')
# sitemap.fetch('sitemap1.xml.gz')
# ```
class Sitemap
  attr_accessor :store

  # @attribute! [r] maps set of sitemap names
  attr_reader :maps

  # @param [Hash] options
  # @option options [ActiveSupport::Cache::Store] store defaults to memory store
  # @option options [URI] :base_url
  # @option options [Boolean] :compress gzip sitemap xml, default true
  # @option options [Array] :links list of pairs [link, options].
  #   e.g. ['/path', changefreq: 'daily', priority: 0.6, lastmod: 3.days.ago]
  def initialize(options = {})
    @store    = options[:store] || ActiveSupport::Cache.lookup_store(:memory_store)
    @links    = options[:links] || []
    @base_url = options[:base_url] || 'http://example.com'
    @compress = !!options[:compress]
    @maps     = Set.new
    @link_set = generate
  end

  def fetch(path, options = {})
    @store.read(normalized_key(path))
  end
  alias_method :[], :fetch

  def index
    fetch('sitemap_index.xml.gz')
  end

  def reset!
    @link_set = nil
  end

  # Ping search engines
  def ping!
    @link_set.ping_search_engines
  end

  def normalized_key(path)
    URI.join(@base_url, path)
  end

  def generate
    link_set = SitemapGenerator::LinkSet.new({
      default_host: @base_url,
      verbose:      false,
      adapter:      self,
      include_root: false
    })

    @links.each {|link, opts| link_set.add(link, opts || {})}
    link_set.create
  end

  # Write sitemap data to cache store. Called by SitemapGenerator
  # @private
  def write(location, raw_data)
    # puts location.inspect
    path = location.filename.to_s
    data = @compress ? ActiveSupport::Gzip.compress(raw_data) : raw_data
    @maps << path
    @store.write(normalized_key(path), data)
  end
end