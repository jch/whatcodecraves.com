require 'test_helper'
require 'util'

class ApplicationTest < ActionDispatch::IntegrationTest
  test "404" do
    get '/foo', remote_addr: '12.12.12'
    assert_response 404
    assert_match /this link doesn't exist/, @response.body
  end

  # Need a separate integration environment that uses production mode
  # otherwise all other tests exceptions are caught
  # test "500" do
  #   get '/error', remote_addr: '12.12.12'
  #   assert_response 500
  #   assert_match /something went wrong/, @response.body
  # end

  test "serves static assets" do
    get '/images/me.jpeg'
    assert_response 200

    get '/files/python_twitter_oauth_sample.zip'
    assert_response 200
  end

  test "links" do
    Blog::Application.load_tasks
    io = capture_stdout do
      Rake::Task['util:crawl'].invoke
    end
    failures = io.read.split("\n").select {|line| line !~ /^200/}
    assert failures.empty?, failures.join("\n")
  end
end
