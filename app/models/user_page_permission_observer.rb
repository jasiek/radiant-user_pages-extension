class UserPagePermissionObserver < ActiveRecord::Observer
  cattr_accessor :current_user

  def before_create(permission)
    if current_user
      raise UserPagesExtension::AccessDenied unless current_user_can?(:permissions, permission.page)
    end
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

  private
  def current_user_can?(action, page)
    @@current_user.admin? or @@current_user.can?(action, page)
  end
end
