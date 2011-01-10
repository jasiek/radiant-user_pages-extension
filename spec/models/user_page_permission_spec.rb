require File.dirname(__FILE__) + '/../spec_helper'

describe UserPagePermission do
  before :each do
    @user_page_permission = UserPagePermission.new
  end

  it "should be valid" do
    @user_page_permission.should be_valid
  end
end
