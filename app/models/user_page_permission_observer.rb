class UserPagePermissionObserver < ActiveRecord::Observer
  cattr_accessor :current_user

  def before_create(permission)
    raise UserPagesExtension::AccessDenied unless @@current_user.can?(:permissions, permission.page)
  end

  def after_create(permission)
    permission.page.children.each do |page|
      page.permissions << permission.clone
    end
  end

  def before_destroy(permission)
    permission.page.children.each do |page|
      page.permissions.find(:all, :conditions => ['user_id = ? AND action = ?', permission.user_id, permission.action]).map(&:destroy)
    end
  end
end
