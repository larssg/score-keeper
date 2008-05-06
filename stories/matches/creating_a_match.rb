require File.expand_path(File.dirname(__FILE__) + '/../helper')

Story "Creating a match", %{
  As a normal user
  I want add mathces
  So that I can brag about it when I win
}, :type => RailsStory do

  Scenario "Entering a match on a 1-on-1 game" do
    Given "a game with a team size of", 1 do |team_size|
      @me, @opponent = Factory.create_people(2, :password => 'test')
      @game = Game.create(:name => 'Test game', :team_size => team_size)
      @gp = @game.game_participations.create(:user => @me)
    end
    And "I have won # matches so far", 0 do |matches_won|
      @gp.update_attribute :matches_won, matches_won
    end
    And "my ranking is", 2000 do |ranking|
      @gp.update_attribute :ranking, ranking
    end
    When "I enter a game with the scores", 10, 5 do |team_one, team_two|
      visits '/'
      
    end
    Then "I should have won # matches", 1 do |matches_won|
    end
  end
end