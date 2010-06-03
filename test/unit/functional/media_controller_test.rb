require File.dirname(__FILE__) + '/../test_helper'
require 'media_controller'

# Re-raise errors caught by the controller.
class MediaController; def rescue_action(e) raise e end; end

class MediaControllerTest < Test::Unit::TestCase
  def setup
    @controller = MediaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_upload
    post :submit_job,
         :media => { :uploaded_data => fixture_file_upload("test.jpg", "image/jpg") },
         :multipart => true
    todo = Todo.find :first
    assert_equal "test.jpg", todo.to_h["OriginalFileName"]
  end

end