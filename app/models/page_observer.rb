class PageObserver < ActiveRecord::Observer
  cattr_accessor :current_user

  def before_create(page)
    if current_user
      raise UserPagesExtension::AccessDenied unless current_user_can?(:create, page.parent)
    end
  end

  def before_destroy(page)
    if current_user
      raise UserPagesExtension::AccessDenied unless current_user_can?(:destroy, page)
      page.permissions.destroy_all
    end
  end

  def before_update(page)
    if current_user
      raise UserPagesExtension::AccessDenied unless current_user_can?(:update, page)
    end
  end

  def after_create(page)
    page.permissions = page.parent.permissions.clone
  end

  private
  def current_user_can?(action, page)
    @@current_user.admin? or @@current_user.can?(action, page)
  end
end
