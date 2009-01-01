require File.dirname(__FILE__) + '/../spec_helper'

describe LogsHelper do
  before(:each) do
    @log = mock_model(Log, :game_id => 1, :linked_id => 2)
  end
  
  it "should generate a match link" do
    @log.stub!(:linked_model).and_return 'Match'
    @log.stub!(:message).and_return 'A game was won'
    
    link = helper.log_link(@log)
    link.should include('<a href="http://test.host/games/1/matches/2">')
    link.should include('/images/icons/game.png')
    link.should include('A game was won')
  end
  
  it "should generate a comment link" do
    @log.stub!(:linked_model).and_return 'Comment'
    @log.stub!(:message).and_return 'Someone said something'

    comment = mock_model(Comment, :match_id => 3)
    Comment.should_receive(:find).with(2).and_return(comment)

    link = helper.log_link(@log)
    link.should include('<a href="http://test.host/games/1/matches/3#c2">')
    link.should include('/images/icons/comment.png')
    link.should include('Someone said something')
  end
  
  it "should show a message without link" do
    @log.stub!(:linked_model).and_return nil
    @log.stub!(:message).and_return 'This is a message with <b>no</b> link'

    link = helper.log_link(@log)
    link.should == 'This is a message with &lt;b&gt;no&lt;/b&gt; link'
  end
  
  it "should generate an atom feed link" do
    game = mock_model(Game, :to_param => '1')   
    current_user = mock_model(User, :feed_token => 'feedtoken')

    helper.log_feed_url(game, {}, current_user).should == 'http://test.host/games/1/logs.atom?feed_token=feedtoken'
  end
end
