require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  before(:each) do
    @membership = Membership.new
  end

  it "should update memberships_count on users"
  
  describe 'logging rankings' do
    before(:each) do
      @people = Factory.create_people(4)

      @game = Factory.create_game
      Factory.create_match(:game => @game, :people => @people)

      # Fix rankings
      [@people[0], @people[1]].each_with_index do |user, index|
        ranking = [1000, 2000][index]
        gp = GameParticipation.find_by_game_id_and_user_id(@game.id, user.id).update_attribute(:ranking, ranking)
      end
    end

    it "should properly log ranking when rank leader is first" do
      match = Factory.create_match(:game => @game, :people => @people)
      team = match.teams.first

      [@people[0], @people[1]].each do |user|
        gp = GameParticipation.find_by_game_id_and_user_id(@game.id, user.id)
        Membership.find_by_team_id_and_user_id(team.id, user.id).current_ranking.should == gp.ranking
      end
    end

    it "should properly log ranking when rank leader is last" do
      match = Factory.create_match(:game => @game, :people => [@people[1], @people[0], @people[2], @people[3]])
      team = match.teams.first

      [@people[0], @people[1]].each do |user|
        gp = GameParticipation.find_by_game_id_and_user_id(@game.id, user.id)
        Membership.find_by_team_id_and_user_id(team.id, user.id).current_ranking.should == gp.ranking
      end
    end
  end
end