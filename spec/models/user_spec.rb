require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    user = Factory(:user)
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate(user.login, 'new password').should == user
  end

  it 'does not rehash password' do
    user = Factory(:user)
    user.update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', user.password).should == user
  end

  it 'authenticates user' do
    user = Factory(:user)
    User.authenticate(user.login, user.password).should == user
  end

  it 'sets remember token' do
    user = Factory(:user)
    user.remember_me
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    user = Factory(:user)
    user.remember_me
    user.remember_token.should_not be_nil
    user.forget_me
    user.remember_token.should be_nil
  end

  it 'remembers me for one week' do
    user = Factory(:user)
    before = 1.week.from_now.utc
    user.remember_me_for 1.week
    after = 1.week.from_now.utc
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
    user.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    user = Factory(:user)
    time = 1.week.from_now.utc
    user.remember_me_until time
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
    user.remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    user = Factory(:user)
    before = 2.weeks.from_now.utc
    user.remember_me
    after = 2.weeks.from_now.utc
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
    user.remember_token_expires_at.between?(before, after).should be_true
  end
  
  it "should get time_zone from account" do
    account = Factory(:account, :time_zone => 'Taipei')
    user = Factory(:user, :account => account, :time_zone => nil)
    user.time_zone.should == 'Taipei'
  end

protected
  def create_user(options = {})
    record = User.new({
      :login => 'quire',
      :email => 'quire@example.com',
      :password => 'quire',
      :password_confirmation => 'quire',
      :name => 'Quire',
      :display_name => 'Quire',
      :time_zone => 'Copenhagen' }.merge(options))
    record.save
    record
  end
end
