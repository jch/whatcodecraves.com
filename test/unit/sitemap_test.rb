require 'test_helper'

class SitemapTest < ActiveSupport::TestCase
  def setup
    stub_posts!
    @sitemap = Sitemap.new({
      base_url: 'http://test.com',
      compress: false,
      links:    [
        ['/path1'],
        ['/path2', {lastmod: Time.now, changefreq: 'daily', priority: 0.3}]
      ]
    })
  end

  test 'fetch index' do
    index = @sitemap.index
    assert_not_nil index

    xml = Nokogiri::XML(index)
    assert_equal ['http://test.com/sitemap1.xml.gz'], xml.css('loc').to_a.map(&:text)
  end

  test 'fetch sitemap' do
    map = @sitemap.fetch('sitemap1.xml.gz')
    assert_not_nil map

    # sitemap includes reference back to index sitemap. not sure if this is in the spec
    links = Nokogiri::XML(map).css('loc').to_a.map(&:text)
    assert links.include?('http://test.com/path1')
    assert links.include?('http://test.com/path2')
  end
end