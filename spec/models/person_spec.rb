require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  before(:each) do
    @person = Person.new
  end

  it "should be valid" do
    @person.should be_valid
  end
end
