require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  before(:each) do
    @person = Person.new
  end

  it "should properly be created by Factory" do
    person = Factory.create_person
    person.should_not be_new_record
    person.should be_valid
  end
  
  it "should format full name" do
    Factory.create_person(:first_name => 'Mike', :last_name => nil).full_name.should == 'Mike'
    Factory.create_person(:first_name => nil, :last_name => 'Tyson').full_name.should == 'Tyson'
    Factory.create_person(:first_name => 'Mike', :last_name => 'Tyson').full_name.should == 'Mike Tyson'
  end
  
  it "should format initials" do
    Factory.create_person(:first_name => 'Mike', :last_name => nil).initials.should == 'M'
    Factory.create_person(:first_name => nil, :last_name => 'Tyson').initials.should == 'T'
    Factory.create_person(:first_name => 'Mike', :last_name => 'Tyson').initials.should == 'MT'
    Factory.create_person(:first_name => 'Mike Fowler', :last_name => 'Tyson').initials.should == 'MFT'
  end
end