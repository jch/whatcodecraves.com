require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  def setup
    stub_posts!
  end

  test "index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posts)
    assert_equal ['November 2012', 'November 2011'], assigns(:posts).keys
  end

  test "show non-existent post" do
    get :show, id: '/whatwhat'
    assert_response :missing
  end

  test "show" do
    get :show, id: '/2011/11/14/this-is-the-title'
    assert_response :success
    assert_not_nil assigns(:post)
  end

  test "show with periods in permalink" do
    assert_routing '/articles/2011/11/14/post-2.2.2-name', {
      controller: 'posts',
      action:     'show',
      id:         '/2011/11/14/post-2.2.2-name'
    }
  end
end