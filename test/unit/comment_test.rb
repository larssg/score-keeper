require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @match = Factory(:match)
  end

  test 'should create a log entry' do
    log_count = Log.count
    Factory(:comment, match: @match)
    assert_equal log_count + 1, Log.count
  end

  test 'should create a log entry linking to the game' do
    log_count = Log.count(conditions: { game_id: @match.game_id })
    Factory(:comment, match: @match)
    assert_equal log_count + 1, Log.count(conditions: { game_id: @match.game_id })
  end
end
