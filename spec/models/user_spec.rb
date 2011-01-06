require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'permissions' do
  before(:each) do
    User.delete_observers
    @user = User.create!
    @page = Page.create!(:title => 'sample_title', :slug => 'sample_title', :breadcrumb => '...', :status => Status.find(1))
    @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page.id, :action => 'create')
  end
  
  it "should allow the user to create a page under the given page by a given user" do
    @user.can?(:create, @page).should be_true
    @user.can?(:destroy, @page).should be_false
  end
end
