require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  before :all do
    @user = User.create!(default_user_params())
    @admin_user = User.create!(default_user_params(:admin => true))
    with_disabled_observers do
      @page_with_permission = Page.create!(default_page_params())
      @page_without_permission = Page.create!(default_page_params())
    end
  end
  
  describe 'creation' do
    before :each do
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'create')
      end
      set_current_user(@user)
    end

    it "should allow the user to create a new page" do
      Page.create!(default_page_params(:parent => @page_with_permission))
    end

    it "should allow the administrator to create a new page unconditionally" do
      set_current_user(@admin_user)
      Page.create!(default_page_params(:parent => @page_without_permission))
    end

    it "should prevent the user from creating a new page" do
      lambda do
        Page.create!(default_page_params(:parent => @page_without_permission))
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      with_disabled_observers do
        @user_page_permission.destroy
      end
    end
  end

  describe 'removal' do
    before :each do
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'destroy')
      end
      set_current_user(@user)
    end

    it "should allow the user to destroy the page" do
      @page_with_permission.destroy
    end

    it "should allow the administrator to destroy a page unconditionally" do
      set_current_user(@admin_user)
      @page_without_permission.destroy
    end

    it "should prevent the user from destroying the page" do
      lambda do
        @page_without_permission.destroy
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      with_disabled_observers do
        @user_page_permission.destroy
      end
    end
  end
  
  describe 'modification' do
    before :each do
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'update')
      end
      set_current_user(@user)
    end

    it "should allow the user to edit the page" do
      @page_with_permission.title = 'hello'
      @page_with_permission.save!
    end

    it "should allow the administrator to edit the page unconditionally" do
      set_current_user(@admin_user)
      @page_without_permission.title = 'hello'
      @page_without_permission.save!
    end

    it "should prevent the user from editing the page" do
      lambda do
        @page_without_permission.title = 'hello'
        @page_without_permission.save!
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      with_disabled_observers do
        @user_page_permission.destroy
      end
    end
  end

  describe 'permission modification' do
    before :each do
      with_disabled_observers do
        @user_page_permission = UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => 'permissions')
      end
      set_current_user(@user)
    end

    it "should allow the user to change permissions" do
      @user_with_permission = @user
      @page_with_permission.permissions.create!(:user_id => @user_with_permission.id, :action => 'create')
    end

    it "should allow the administrator to change user permissions unconditionally" do
      set_current_user(@admin_user)
      @page_without_permission.permissions.create!(:user_id => @user.id, :action => 'create')
    end

    it "should prevent the user from changing permissions" do
      @user_without_permission = @user
      lambda do
        @page_without_permission.permissions.create!(:user_id => @user_without_permission.id, :action => 'create')
      end.should raise_exception(UserPagesExtension::AccessDenied)
    end

    after :each do
      with_disabled_observers do
        @user_page_permission.destroy
      end
    end
  end

  describe 'permission propagation on creation' do
    before :each do
      with_disabled_observers do
        ['create', 'destroy', 'update'].each do |action|
          UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => action)
        end
      end
      set_current_user(@user)
    end

    it 'should copy permissions from parent to child when a new page is created' do
      @new_page = Page.create!(default_page_params(:parent => @page_with_permission))
      @new_page.permissions.count.should > 0
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
      set_current_user(@user)
    end

    it 'should remove all permissions related to a particular page' do
      permission_count_before_removal = UserPagePermission.count
      @page_with_permission.destroy
      UserPagePermission.count.should_not == permission_count_before_removal
    end
  end

  describe 'permissions are changeable if permissions allow it' do
    before :each do
      with_disabled_observers do
        @page_one_below = Page.create!(default_page_params(:parent => @page_with_permission))
        @page_two_below = Page.create!(default_page_params(:parent => @page_one_below))
        ['create', 'permissions'].each do |action|
          UserPagePermission.create!(:user_id => @user.id, :page_id => @page_with_permission.id, :action => action)
          UserPagePermission.create!(:user_id => @user.id, :page_id => @page_one_below.id, :action => action)
          UserPagePermission.create!(:user_id => @user.id, :page_id => @page_two_below.id, :action => action)
        end
      end
      set_current_user(@user)
    end

    it 'should propagate all permission changes down the tree' do
      @page_with_permission.permissions.create(:user => @user, :action => 'destroy')
      @page_with_permission.permissions.find(:first, :conditions => ['action = ?', 'create']).destroy
      [@page_with_permission, @page_one_below, @page_two_below].each do |page|
        page.permissions.map(&:action).to_set.should == Set['destroy', 'permissions']
      end
    end
  end

  after :all do
    with_disabled_observers do
      User.destroy_all
      Page.destroy_all
      UserPagePermission.destroy_all
    end
  end
end
