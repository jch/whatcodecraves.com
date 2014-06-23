require 'test_helper'

# Shared regression and smoke tests for a given environment.
#
module ProductionTests
  extend ActiveSupport::Concern

  def http
    @http ||= Faraday.new(url: self.class.base_url)
  end

  def smoke(path)
    res = http.get(path)
    assert_equal res.status, 200
    assert res.body.size > 0
    res
  end

  module ClassMethods
    attr_writer :base_url

    # Public: Returns string url to be base tests upon.
    def base_url
      return @base_url if defined?(@base_url)
      raise NotImplementedError.new "Missing base_url for tests"
    end
  end

  included do
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
end

class HerokuTest < ActiveSupport::TestCase
  include ProductionTests

  self.base_url = 'http://www.whatcodecraves.com/'

  test "redirects without www" do
    res = Faraday.get 'http://whatcodecraves.com'
    assert_equal res.status, 302
    assert_equal 'http://www.whatcodecraves.com/', res.headers['Location']
  end
end
