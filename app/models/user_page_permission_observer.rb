class UserPagePermissionObserver < ActiveRecord::Observer
  cattr_accessor :current_user

  def before_create(permission)
    raise UserPagesExtension::AccessDenied unless @@current_user.can?(:permissions, permission.page)
  end
end
