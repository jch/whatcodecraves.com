require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    stub_posts!
    @post = Post.new('/2011/11/14/this-is-the-title')
  end

  test ".all" do
    all = Post.all
    assert_equal 2, all.size
    assert all.all? {|e| e.kind_of? Post}, "results should be posts"
  end

  test ".recent" do
    recent = Post.recent(1)
    assert_equal 1, recent.size
    assert recent.all? {|e| e.kind_of? Post}, "results should be posts"
    assert_equal '/2012/11/14/another-post', recent.first.permalink
  end

  test "exists?" do
    assert @post.exists?
  end

  test "permalink" do
    assert_equal '/2011/11/14/this-is-the-title', @post.permalink
  end

  test "raw" do
    assert_equal File.read(Post.root_path + '2011/11/14/this_is_the_title/index.text'),
      @post.raw
  end

  test "title" do
    assert_equal "This is the Title", @post.title
  end

  test "date" do
    assert_equal Date.parse('2011-11-14'), @post.date
  end

  test "description" do
    assert_equal "<p>This is some content</p><p>This is some more content</p>", @post.description
  end

  test "html" do
    assert @post.html =~ %r{<h1>This is the Title</h1>}
  end

  test "updated_at" do
    t = @post.updated_at
    assert_equal @post.updated_at, t
    `touch #{@post.directory.expand_path}`
    assert @post.updated_at > t
  end

  test "<=>" do
    assert Post.new('/2011/11/14/this-is-the-title') < Post.new('/2012/11/14/another-post')
    assert_equal Post.new('/2011/11/14/this-is-the-title'), Post.new('/2011/11/14/this-is-the-title')
    assert Post.new('/2012/11/14/another-post') > Post.new('/2011/11/14/this-is-the-title')
  end
end