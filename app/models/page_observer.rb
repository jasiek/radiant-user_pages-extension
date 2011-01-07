class PageObserver < ActiveRecord::Observer
  cattr_accessor :current_user

  def before_create(page)
    raise UserPagesExtension::AccessDenied unless @@current_user.can?(:create, page)
  end

  def before_destroy(page)
    raise UserPagesExtension::AccessDenied unless @@current_user.can?(:destroy, page)
  end

  def before_update(page)
    raise UserPagesExtension::AccessDenied unless @@current_user.can?(:update, page)
  end
end
