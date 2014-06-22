require 'test_helper'

# Regressions, smoke tests
class ProductionTest < ActiveSupport::TestCase
  def http
    @http ||= Faraday.new(url: 'http://www.whatcodecraves.com')
  end

  def smoke(path)
    res = http.get(path)
    assert_equal res.status, 200
    assert res.body.size > 0
    res
  end

  test "redirects without www" do
    res = Faraday.get 'http://whatcodecraves.com'
    assert_equal res.status, 302
    assert_equal 'http://www.whatcodecraves.com/', res.headers['Location']
  end

  test "home" do
    smoke '/'
  end

  test "archives" do
    smoke '/articles'
  end

  test "robots" do
    smoke '/robots.txt'
  end

  test "rss" do
    smoke '/rss.xml'
  end

  test "sitemap links" do
    smoke '/sitemap_index.xml.gz'
    smoke '/sitemap1.xml.gz'
  end

  test "disqus" do
    # requires capybara-webkit
  end
end
