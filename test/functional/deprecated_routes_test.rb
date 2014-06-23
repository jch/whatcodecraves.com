require 'test_helper'

class DeprecatedRoutesTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.app do
      use DeprecatedRoutes
      run lambda {|env| [200, {}, ['endpoint']]}
    end
  end

  test "pass through non-post paths" do
    get '/foo'
    assert_equal 200, last_response.status
  end

  test "pass through canonical permalinks" do
    get '/posts/2011/11/14/some-title'
    assert_equal 200, last_response.status
  end

  test "301 underscores to dashes" do
    get '/articles/2011/11/14/some_title'
    assert_equal 301, last_response.status
    assert_equal 'http://example.org/posts/2011/11/14/some-title', last_response.headers['Location']
  end

  test "301 index.html to folder" do
    get '/articles/2011/11/14/title/index.html'
    assert_equal 301, last_response.status
    assert_equal 'http://example.org/posts/2011/11/14/title', last_response.headers['Location']
  end

  test "301 trailing slash" do
    get '/articles/2011/11/14/title/'
    assert_equal 301, last_response.status
    assert_equal 'http://example.org/posts/2011/11/14/title', last_response.headers['Location']
  end

  test "301 punctuation" do
    get '/articles/2011/11/14/PROJECT_README,Y_U_NO_HAVE?'
    assert_equal 301, last_response.status
    assert_equal 'http://example.org/posts/2011/11/14/project-readme-y-u-no-have', last_response.headers['Location']
  end

  test "301 archives to posts" do
    get '/archives'
    assert_equal 301, last_response.status
    assert_equal 'http://example.org/posts', last_response.headers['Location']
  end
end
