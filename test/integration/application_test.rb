require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
  test "404" do
    get '/foo', remote_addr: '12.12.12'
    assert_response 404
    assert_match /this link doesn't exist/, @response.body
  end

  test "500" do
    get '/error', remote_addr: '12.12.12'
    assert_response 500
    assert_match /something went wrong/, @response.body
  end
end
