require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  before(:each) do
    @membership = Membership.new
  end

  it "should be valid" do
    @membership.should be_valid
  end
end
