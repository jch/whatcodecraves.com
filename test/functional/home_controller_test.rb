require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
    assert_equal @response.headers['Last-Modified'], Post.last_modified.httpdate
  end

  test "sitemap index" do
    get :sitemap, id: '_index.xml.gz'
    assert_response :success
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
    assert_match @response.body, %r{sitemap1.xml.gz</loc>}
  end

  test "sitemap map" do
    get :sitemap, id: '1.xml.gz'
    assert_response :success
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
    assert_match @response.body, %r{/2008/05/03/kernel-designs</loc>}
  end

  test "robots.txt" do
    get :robots
    assert_response :success
    assert_equal 'text/plain; charset=utf-8', @response.headers['Content-Type']
    assert_equal @response.body.strip, 'Sitemap: http://test.host/sitemap_index.xml.gz'
  end
end