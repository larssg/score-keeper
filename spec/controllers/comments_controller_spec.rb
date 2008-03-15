require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  fixtures :users, :accounts

  before(:each) do
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
  end

  it "should add a comment on a match" do
    lambda do
      @match = Factory.create_match(:account => controller.current_account)
      post :create, :match_id => @match.id, :comment => { :body => 'This is a comment' }
      response.should be_redirect
      response.should redirect_to(match_path(@match))

      @match.reload
      @match.comments.first.body.should == 'This is a comment'
    end.should change(Comment, :count).by(1)
  end
end