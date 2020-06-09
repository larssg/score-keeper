require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  setup do
    @account = Account.new
  end
  
  test "should require a name" do
    @account.name = ''
    @account.domain = 'test'
    assert_not @account.valid?
    assert_equal ["can't be blank"], @account.errors[:name]
  end
  
  test "should not allow 'a test' as a domain" do
    @account.name = 'A test'
    @account.domain = 'a test'
    assert_not @account.valid?
  end
  
  test "should allow 'test' as a domain" do
    @account.name = 'Test'
    @account.domain = 'test'
    assert @account.valid?
  end
  
  test "should not allow 'Test' as a domain" do
    @account.name = 'Test'
    @account.domain = 'Test'
    assert_not @account.valid?
  end
  
  test "should not allow 2 accounts to have the same domain" do
    @account.name = 'Test 1'
    @account.domain = 'test'
    @account.save!
    
    other_account = Account.new(:name => 'Test 2', :domain => 'test')
    assert_not other_account.save
    assert_equal ['has already been taken'], other_account.errors[:domain]
  end
end
