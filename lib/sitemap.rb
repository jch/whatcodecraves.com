require 'uri'

# SitemapGenerator::Sitemap.search_engines
# Sitemap: http://www.example.com/sitemap_index.xml.gz
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
  end

  def fetch(path, options = {})
    @link_set ||= generate
    @store.read(normalized_key(path))
  end
  alias_method :[], :fetch

  def index
    fetch('sitemap_index.xml.gz')
  end

  def reset!
    @link_set = nil
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