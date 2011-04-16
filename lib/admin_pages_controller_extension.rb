module AdminPagesControllerExtension
  def self.included(base)
    base.before_filter :attach_css
    base.around_filter :persist_permissions_on_update, :only => :update
    base.around_filter :persist_permissions_on_create, :only => :create
  end

  def attach_css
    include_stylesheet 'admin/user_page'
  end

  def persist_permissions_on_update(&blk)
    UserPagePermission.transaction do
      clear_and_restore_permissions(@page, params[:page][:permissions] || [])
      params[:page].delete(:permissions)
      yield
    end
  end

  def persist_permissions_on_create(&blk)
    UserPagePermission.transaction do
      permissions = params[:page].delete(:permissions)
      yield
      clear_and_restore_permissions(@page, permissions)
    end
  end

  def rescue_action(exception)
    if exception.is_a?(UserPagesExtension::AccessDenied)
      @page.errors.add(:permissions, t('activerecord.errors.models.page.attributes.permissions.error'))
      response_for :invalid
    else
      super
    end
  end

  private
  def clear_and_restore_permissions(page, permissions)
    return if no_changes_to_permissions?(page.permissions, permissions)
    page.permissions.clear
    permissions.each do |query_string|
      next if query_string.empty?
      user_id, action = query_string.split(/,/)
      page.permissions.create!(:user => User.find(user_id), :action => action)
    end
  end

  def no_changes_to_permissions?(array_of_permissions, permissions_query_string)
    old_permission_set = array_of_permissions.map do |permission|
      [permission.user_id, permission.action]
    end.to_set
    new_permission_set = permissions_query_string.reject do |query_string|
      query_string.empty?
    end.map do |query_string|
      user_id, action = query_string.split(/,/)
      [user_id.to_i, action]
    end.to_set
    old_permission_set == new_permission_set
  end
end
