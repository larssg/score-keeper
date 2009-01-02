require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  before(:each) do
    @membership = Membership.new
  end

  it "should update memberships_count on users"
  
  describe 'logging rankings' do
    before(:each) do
      @match = Factory(:match)
      @game = @match.game

      # Fix rankings
      [@match.team1[0], @match.team1[1]].each_with_index do |user_id, index|
        user = User.find(user_id)
        ranking = [1000, 2000][index]
        gp = GameParticipation.find_by_game_id_and_user_id(@game.id, user.id).update_attribute(:ranking, ranking)
      end
    end

    it "should properly log ranking when rank leader is first" do
      match = Factory(:match, :game => @game, :team1 => @match.team1, :team2 => @match.team2)
      team = match.teams.first

      [@match.team1[0], @match.team1[1]].each do |user_id|
        user = User.find(user_id)
        gp = GameParticipation.find_by_game_id_and_user_id(@game.id, user.id)
        Membership.find_by_team_id_and_user_id(team.id, user.id).current_ranking.should == gp.ranking
      end
    end

    it "should properly log ranking when rank leader is last" do
      reversed_team = @match.team1.reverse
      match = Factory(:match, :game => @game, :team1 => reversed_team, :team2 => @match.team2)
      team = match.teams.first

      [@match.team1[0], @match.team1[1]].each do |user_id|
        user = User.find(user_id)
        gp = GameParticipation.find_by_game_id_and_user_id(@game.id, user.id)
        Membership.find_by_team_id_and_user_id(team.id, user.id).current_ranking.should == gp.ranking
      end
    end
  end
end
