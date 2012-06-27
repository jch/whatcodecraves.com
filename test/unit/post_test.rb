require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    stub_posts!
    @post = Post.from_permalink('/2011/11/14/this-is-the-title')
  end

  test ".from_permalink" do
    assert_not_nil @post
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

  test "html" do
    assert @post.html =~ %r{<h1>This is the Title</h1>}
  end

  test "<=>" do
    assert Post.new('/2011/11/14/foo', '') < Post.new('/2012/11/14/foo', '')
    assert_equal Post.new('/2011/11/14/foo', ''), Post.new('/2011/11/14/foo', '')
    assert Post.new('/2012/11/14/foo', '') > Post.new('/2011/11/14/foo', '')
  end
end