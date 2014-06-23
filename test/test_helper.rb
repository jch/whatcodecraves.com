ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Set `Post.root_path` to test/fixtures
  def stub_posts!(path = nil)
    path ||= 'test/fixtures/posts'
    Post.root_path = Rails.root + path
  end
end
