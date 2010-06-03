require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < Test::Unit::TestCase
  fixtures :messages

  def test_single_table_inheritance
    Done.create(:body => "key, value")
    Todo.create(:body => "key, value")

    dones = Done.find :all
    assert_equal 1, dones.size

    todos = Todo.find :all
    assert_equal 1, todos.size

    messages = Message.find :all
    assert_equal 4, messages.size
  end

end
