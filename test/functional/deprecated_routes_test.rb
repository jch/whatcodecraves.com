require 'test_helper'

class DeprecatedRoutesTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.app do
      use DeprecatedRoutes
      run lambda {|env| [200, {}, ['endpoint']]}
    end
  end

  test "should pass through non-article paths" do
    get '/foo'
    assert_equal 200, last_response.status
  end

  test "should pass through canonical permalinks" do
    get '/articles/2011/11/14/some-title'
    assert_equal 200, last_response.status
  end

  test "should 301 underscores to dashes" do
    get '/articles/2011/11/14/some_title'
    assert_equal 301, last_response.status
    assert_equal '/articles/2011/11/14/some-title', last_response.headers['Location']
  end

  test "should 301 index.html to folder" do
    get '/articles/2011/11/14/title/index.html'
    assert_equal 301, last_response.status
    assert_equal '/articles/2011/11/14/title', last_response.headers['Location']
  end

  test "should 301 trailing slash" do
    get '/articles/2011/11/14/title/'
    assert_equal 301, last_response.status
    assert_equal '/articles/2011/11/14/title', last_response.headers['Location']
  end
end