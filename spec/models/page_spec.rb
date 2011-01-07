require File.dirname(__FILE__) + '/../spec_helper'

def random_string
  Digest::SHA1.hexdigest(Kernel.rand.to_s)
end

describe Page do
  before :all do
    @user = User.create!
    PageObserver.current_user = @user
    @page_with_permission = Page.create!(:title => random_string(), :slug => random_string(), :breadcrumb => random_string(), :status => Status.find(1))
    @page_without_permission = Page.create(:title => random_string(), :slug => random_string(), :breadcrumb => random_string(), :status => Status.find(1))
  end
  
  describe 'creation' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page_with_permission, :action => 'create')
    end

    it "should allow the user to create a new page" do
      Page.create!(:parent => @page_with_permission, :title => random_string(), :slug => random_string(), :breadcrumb => random_string(), :status => Status.find(1))
    end

    it "should prevent the user from creating a new page" do
      lambda do
        Page.create!(:parent => @page_without_permission, :title => random_string(), :slug => random_string(), :breadcrumb => random_string(), :status => Status.find(1))
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  describe 'removal' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page_with_permission, :action => 'destroy')
    end

    it "should allow the user to destroy the page" do
      @page_with_permission.destroy
    end

    it "should prevent the user from destroying the page" do
      lambda do
        @page_without_permission.destroy
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      @user_page_permission.destroy
    end
  end
  
  describe 'modification' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page_with_permission, :action => 'update')
    end

    it "should allow the user to edit the page" do
      @page_with_permission.title = 'hello'
      @page_with_permission.save!
    end

    it "should prevent the user from editing the page" do
      lambda do
        @page_without_permission.title = 'hello'
        @page_without_permission.save!
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  describe 'permission modification' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page_with_permission, :action => 'permissions')
    end

    it "should allow the user to change permissions" do
    end

    it "should prevent the user from changing permissions" do
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  after :all do
    @user.destroy
  end
end
