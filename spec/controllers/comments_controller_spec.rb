require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory(:game)
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(@game.account)

    @user = Factory(:user, :account => @game.account)
    login_as @user
  end

  it "should add a comment on a match" do
    lambda do
      @match = Factory(:match, :account => @game.account, :game => @game)
      post :create, :match_id => @match.id, :comment => { :body => 'This is a comment' }
      response.should be_redirect
      response.should redirect_to(game_match_path(@match.game, @match))

      @match.reload
      @match.comments.first.body.should == 'This is a comment'
    end.should change(Comment, :count).by(1)
  end
end
