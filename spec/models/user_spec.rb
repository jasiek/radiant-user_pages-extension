require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'permissions' do
  before :each do
    with_disabled_observers do
      @user = User.create!
      @page = Page.create!(:title => 'sample_title', :slug => 'sample_title', :breadcrumb => '...', :status => Status.find(1))
      @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page.id, :action => 'create')
    end
  end
  
  it "should allow the user to create a page under the given page by a given user" do
    @user.can?(:create, @page).should be_true
    @user.can?(:destroy, @page).should be_false
  end

  after :each do
    with_disabled_observers do
      @user.destroy
      @page.destroy
      @user_page_permission.destroy
    end
  end
end
