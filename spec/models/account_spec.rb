require File.dirname(__FILE__) + '/../spec_helper'

describe Account do
  before(:each) do
    @account = Account.new
  end
  
  it "should require a name" do
    @account.name = ''
    @account.domain = 'test'
    @account.should_not be_valid
    @account.errors[:name].should == "can't be blank"
  end

  it "should not allow 'a test' as a domain" do
    @account.name = 'A test'
    @account.domain = 'a test'
    @account.should_not be_valid
  end
  
  it "should allow 'test' as a domain" do
    @account.name = 'Test'
    @account.domain = 'test'
    @account.should be_valid
  end
  
  it "should not allow 'Test' as a domain" do
    @account.name = 'Test'
    @account.domain = 'Test'
    @account.should_not be_valid
  end
  
  it "should not allow 2 accounts to have the same domain" do
    @account.name = 'Test 1'
    @account.domain = 'test'
    @account.save!
    
    other_account = Account.new(:name => 'Test 2', :domain => 'test')
    other_account.save.should be_false
    other_account.errors[:domain].should == 'has already been taken'
  end
end
