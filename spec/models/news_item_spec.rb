require File.dirname(__FILE__) + '/../spec_helper'

describe NewsItem do
  before(:each) do
    @news_item = NewsItem.new
  end

  it "should be valid" do
    @news_item.should be_valid
  end
end
