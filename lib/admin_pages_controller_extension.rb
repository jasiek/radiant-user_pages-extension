module AdminPagesControllerExtension
  def self.included(base)
    base.before_filter :attach_css
    base.around_filter :persist_permissions, :only => :update
  end

  def attach_css
    include_stylesheet 'admin/user_page'
  end

  def persist_permissions(&blk)
    UserPagePermission.transaction do
      @page.permissions.clear
      params[:page][:permissions].each do |query_string|
        next if query_string.empty?
        user_id, action = query_string.split(/,/)
        @page.permissions.create!(:user => User.find(user_id), :action => action)
      end
      params[:page].delete(:permissions)
      yield
    end
  end
end
