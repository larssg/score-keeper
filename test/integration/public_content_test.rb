require File.dirname(__FILE__) + '/../test_helper'

class PublicContentTest < ActionController::IntegrationTest
  test "should be redirected to /p when going to /" do
    get '/'
    assert_response :redirect
    assert_redirected_to '/p'
  end
end
