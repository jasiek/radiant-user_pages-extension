require File.dirname(__FILE__) + '/../spec_helper'

def random_string
  Digest::SHA1.hexdigest(Kernel.rand.to_s)
end

def default_status
  Status.find(1)
end

def default_page_params(additional_params={})
  {
    :title => random_string(),
    :slug => random_string(),
    :breadcrumb => random_string(),
    :status => default_status()
  }.merge(additional_params)
end

def default_user_params(additional_params={})
  {
    :login => random_string(),
    :name => random_string(),
    :password => 'wyborowa',
    :password_confirmation => 'wyborowa'
  }.merge(additional_params)
end

def with_disabled_observers(&blk)
  Page.delete_observers
  UserPagePermission.delete_observers
  blk.call
  PageObserver.instance.send(:add_observer!, Page)
  UserPagePermissionObserver.instance.send(:add_observer!, UserPagePermission)
end

describe Page do
  before :all do
    @user = User.create!(default_user_params()) 
    with_disabled_observers do
      @page_with_permission = Page.create!(default_page_params())
      @page_without_permission = Page.create!(default_page_params())
    end
    PageObserver.current_user = @user
    UserPagePermissionObserver.current_user = @user
  end
  
  describe 'creation' do
    before :each do
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'create')
      end
    end

    it "should allow the user to create a new page" do
      Page.create!(default_page_params(:parent => @page_with_permission))
    end

    it "should prevent the user from creating a new page" do
      lambda do
        Page.create!(default_page_params(:parent => @page_without_permission))
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  describe 'removal' do
    before :each do
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'destroy')
      end
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
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'update')
      end
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
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'permissions')
      end
    end

    it "should allow the user to change permissions" do
      @user_with_permission = @user
      @page_with_permission.permissions.create!(:user_id => @user_with_permission.id, :action => 'create')
    end

    it "should prevent the user from changing permissions" do
      @user_without_permission = @user
      lambda do
        @page_without_permission.permissions.create!(:user_id => @user_without_permission.id, :action => 'create')
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  describe 'permission propagation on creation' do
    before :each do
      with_disabled_observers do
        ['create', 'destroy', 'update'].each do |action|
          UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => action)
        end
      end
    end

    it 'should copy permissions from parent to child when a new page is created' do
      @new_page = Page.create!(default_page_params(:parent => @page_with_permission))
      Set[@new_page.permissions.map(&:action)].should == Set[@page_with_permission.permissions.map(&:action)]
    end
  end

  describe 'permission removal on page removal' do
    before :each do
      with_disabled_observers do
        ['create', 'destroy', 'update'].each do |action|
          UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => action)
        end
      end
    end

    it 'should remove all permissions related to a particular page' do
      permission_count_before_removal = UserPagePermission.count
      @page_with_permission.destroy
      UserPagePermission.count.should_not == permission_count_before_removal
    end
  end

  after :all do
    @user.destroy
  end
end
