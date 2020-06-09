# frozen_string_literal: true
require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  test "deleting a game properly updates rankings, win totals, etc." do
    game = Factory(:game)
    users = (0..3).collect { Factory(:user) }

    # Create 10 games
    matches = (0..9).collect {
      game.matches.create!(
        :account => game.account,
        :team1 => [users[0].id.to_s, users[1].id.to_s],
        :score1 => 10,
        :team2 => [users[2].id.to_s, users[3].id.to_s],
        :score2 => 4)
    }

    # Validate data
    assert_equal 4, User.count
    
    assert_equal 10, Match.count

    users.each do |user|
      assert_equal 10, user.memberships.count
    end

    # Check winners
    winner_rankings = [4040, 4080, 4119, 4158, 4196, 4234, 4272, 4309, 4346, 4383]

    ranking_sums = []
    [users[0], users[1]].each do |user|
      user.memberships.order('id').each_with_index do |membership, index|
        ranking_sums[index] = ranking_sums[index].to_i + membership.current_ranking
      end
    end
    
    assert_equal winner_rankings, ranking_sums

    # Check losers
    loser_rankings = [3960, 3920, 3881, 3842, 3804, 3766, 3728, 3691, 3654, 3617]

    ranking_sums = []
    [users[2], users[3]].each do |user|
      user.memberships.order('id').each_with_index do |membership, index|
        ranking_sums[index] = ranking_sums[index].to_i + membership.current_ranking
      end
    end
    
    assert_equal loser_rankings, ranking_sums
    
    ### Delete match
    deleted_match_id = matches[-2].id
    matches[-2].destroy
  
    # Validate data
    assert !Match.exists?(deleted_match_id)
    
    assert_equal 9, Match.count

    users.each do |user|
      assert_equal 9, user.memberships.count
    end

    # Check winners
    winner_rankings = [4040, 4080, 4119, 4158, 4196, 4234, 4272, 4309, 4346]

    ranking_sums = []
    [users[0], users[1]].each do |user|
      user.memberships.order('id').each_with_index do |membership, index|
        ranking_sums[index] = ranking_sums[index].to_i + membership.current_ranking
      end
    end
    
    assert_equal winner_rankings, ranking_sums

    # Check losers
    loser_rankings = [3960, 3920, 3881, 3842, 3804, 3766, 3728, 3691, 3654]

    ranking_sums = []
    [users[2], users[3]].each do |user|
      user.memberships.order('id').each_with_index do |membership, index|
        ranking_sums[index] = ranking_sums[index].to_i + membership.current_ranking
      end
    end
    
    assert_equal loser_rankings, ranking_sums
  end
end