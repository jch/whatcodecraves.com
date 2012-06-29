require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
    assert_equal @response.headers['Last-Modified'], Post.last_modified.httpdate
  end
end