require 'test_helper'
require 'pathname_extensions'
require 'set'

class PathnameExtensionsTest < ActiveSupport::TestCase
  def setup
    @pathname = Pathname.new(File.dirname(__FILE__))
  end

  test "inclusion" do
    assert Pathname.included_modules.include? PathnameExtensions
    assert Pathname.included_modules.include? Enumerable
  end

  test "enumerable" do
    assert_equal Enumerator, @pathname.each.class
  end

  test "search default returns all children excluding self" do
    assert_equal Set.new(@pathname.to_a), Set.new(@pathname.search.to_a)
  end

  test "search string" do
    assert_equal [Pathname.new('test/unit/.gitkeep').expand_path], @pathname.search('.gitkeep').map(&:expand_path)
  end

  test "search regexp" do
    assert_equal [Pathname.new('test/unit/.gitkeep').expand_path], @pathname.search(/.gitk..p/).map(&:expand_path)
  end

  test "post?" do
    assert Pathname.new(File.expand_path('../../fixtures/articles/2011/11/14/this_is_the_title', __FILE__)).post?
    assert !Pathname.new('test/unit/.gitkeep').post?  # must be directory
    assert !Pathname.new('test/unit').post?           # missing index.text
  end
end