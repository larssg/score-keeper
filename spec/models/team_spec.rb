require File.dirname(__FILE__) + '/../spec_helper'

describe Team do
  before(:each) do
    @team = Team.new
  end

  it "should be valid" do
    @team.should be_valid
  end
end
