require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  def setup
    stub_posts!
  end

  test "index html" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posts)
    assert_equal ['November 2012', 'November 2011'], assigns(:posts).keys
  end

  test "index rss" do
    get :index, format: 'xml'
    assert_response :success
    doc = Nokogiri::XML(@response.body)
    posts = doc.css('item')
    assert_equal 2, posts.size
    assert_equal 'This is the Title', posts.last.css('title').text
    assert_equal '<p>This is some content</p>', posts.last.css('description').text.strip
    assert_equal 'http://test.host/articles/2011/11/14/this-is-the-title', posts.last.css('link').text
  end

  test "index rss route" do
    assert_recognizes({
      controller: 'posts',
      action:     'index',
      format:     'xml'
    }, '/rss.xml')
  end

  test "show non-existent post" do
    get :show, id: '/whatwhat'
    assert_response :missing
  end

  test "show" do
    get :show, id: '/2011/11/14/this-is-the-title'
    assert_response 200
    assert_equal @response.headers['Last-Modified'], assigns(:post).updated_at.in_time_zone.httpdate
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