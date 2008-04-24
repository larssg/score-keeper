require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory.create_game
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
  end

  it "should add a comment on a match" do
    lambda do
      @match = Factory.create_match(:account => controller.current_account, :game => @game)
      post :create, :match_id => @match.id, :comment => { :body => 'This is a comment' }
      response.should be_redirect
      response.should redirect_to(game_match_path(@match.game, @match))

      @match.reload
      @match.comments.first.body.should == 'This is a comment'
    end.should change(Comment, :count).by(1)
  end
end