require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "has a valid factory" do
    game = Factory(:game)
    assert game.valid?
  end
  
  test "deleting a game deletes all relevant data" do
    game = Factory(:game, :team_size => 2)
    match = Factory(:match, :game => game)
    comment = Factory(:comment, :match => match)

    # Make sure there is data in the database
    assert_equal 1, Game.count
    assert_equal 1, Comment.count
    assert_equal 4, GameParticipation.count
    assert_equal 2, Log.count
    assert_equal 1, Match.count
    assert_equal 4, Membership.count
    assert_equal 2, Team.count
    
    # Delete the game
    game.destroy
    
    # Verify that the database is empty
    assert_equal 0, Game.count
    assert_equal 0, Comment.count
    assert_equal 0, GameParticipation.count
    assert_equal 0, Log.count
    assert_equal 0, Match.count
    assert_equal 0, Membership.count
    assert_equal 0, Team.count
  end
  
  test "deleting a game does not delete other games' data" do
    foosball = Factory(:game)
    foosball_match = Factory(:match, :game => foosball)
    foosball_comment = Factory(:comment, :match => foosball_match)
    
    pool = Factory(:game)
    pool_match = Factory(:match, :game => pool)
    pool_comment = Factory(:comment, :match => pool_match)
    
    # Make sure there is data in the databse
    assert_equal 2, Game.count
    assert_equal 2, Comment.count
    assert_equal 8, GameParticipation.count
    assert_equal 4, Log.count
    assert_equal 2, Match.count
    assert_equal 8, Membership.count
    assert_equal 4, Team.count
    
    # Delete the game
    foosball.destroy
    
    # Verify that only data for foosball was deleted
    assert_equal 1, Game.count
    assert_equal 1, Comment.count
    assert_equal 4, GameParticipation.count
    assert_equal 2, Log.count
    assert_equal 1, Match.count
    assert_equal 4, Membership.count
    assert_equal 2, Team.count

    pool.reload
    pool_match.reload
    assert_equal 1, pool.matches.count
    assert_equal 2, pool.logs.count
    assert_equal 4, pool.game_participations.count
    assert_equal 4, pool.memberships.count
    assert_equal 1, pool_match.comments.count
    assert_equal 2, pool_match.teams.count
  end
end