require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  fixtures :users, :accounts

  before(:each) do
    login_as :aaron
  end

  it "should add a comment on a game" do
    lambda do
      @game = Factory.create_game
      post :create, { :game_id => @game.id, :comment => { :body => 'This is a comment' } }, { :host => 'champions.test.host' }
      response.should be_redirect
      response.should redirect_to(game_path(@game))

      @game.reload
      @game.comments.first.body.should == 'This is a comment'
    end.should change(Comment, :count).by(1)
  end
end