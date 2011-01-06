require File.dirname(__FILE__) + '/../spec_helper'

def random_string
  Digest::SHA1.hexdigest(Kernel.rand.to_s)
end

describe Page do
  before :all do
    @user = User.create!
    @page = Page.create!(:title => random_string(), :slug => random_string(), :breadcrumb => random_string(), :status => Status.find(1))
  end
  
  describe 'creation' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page, :action => 'create')
    end

    it "should allow the user to create a new page" do
      Page.create!(:parent => @page, :title => random_string(), :slug => random_string(), :breadcrumb => random_string(), :status => Status.find(1))
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  describe 'removal' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page, :action => 'destroy')
    end

    it "should allow the user to destroy the page" do
      @page.destroy
    end

    after :each do
      @user_page_permission.destroy
    end
  end
  
  describe 'modification' do
    before :each do
      @user_page_permission = UserPagePermission.create!(:user_id => @user, :page_id => @page, :action => 'update')
    end

    it "should allow the user to edit the page" do
      @page.title = 'hello'
      @page.save!
    end

    after :each do
      @user_page_permission.destroy
    end
  end

  after :all do
    @user.destroy
  end
end
