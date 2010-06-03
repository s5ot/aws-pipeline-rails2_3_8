require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/activemessaging/lib/activemessaging/test_helper'
require File.dirname(__FILE__) + '/../../app/processors/application'

class MessageProcessorTest < Test::Unit::TestCase
  include ActiveMessaging::TestHelper
  
  def setup
    load File.dirname(__FILE__) + "/../../app/processors/message_processor.rb"
    @processor = MessageProcessor.new
  end
  
  def teardown
    @processor = nil
  end  

  def test_message_processor
    @processor.on_message "Test Message"
  
    message = Done.find :first
  
    assert_equal message.body, "Test Message"
  end

end
