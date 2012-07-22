require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
    assert_equal @response.headers['Last-Modified'], Post.last_modified.httpdate
    assert_match %r{<title>\nJerry Cheung's Tech Portfolio\n</title>}, @response.body
  end

  test "robots.txt" do
    get :robots
    assert_response :success
    assert_equal 'text/plain; charset=utf-8', @response.headers['Content-Type']
    assert_equal @response.body.strip, 'Sitemap: http://test.host/sitemap_index.xml.gz'
  end
end