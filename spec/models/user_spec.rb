require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end

  it "should properly be created by Factory" do
    user = Factory.create_user
    user.should_not be_new_record
    user.should be_valid
  end
  
  it "should format initials" do
    Factory.create_user(:first_name => 'Mike', :last_name => nil).initials.should == 'M'
    Factory.create_user(:first_name => nil, :last_name => 'Tyson').initials.should == 'T'
    Factory.create_user(:first_name => 'Mike', :last_name => 'Tyson').initials.should == 'MT'
    Factory.create_user(:first_name => 'Mike Fowler', :last_name => 'Tyson').initials.should == 'MFT'
  end
end