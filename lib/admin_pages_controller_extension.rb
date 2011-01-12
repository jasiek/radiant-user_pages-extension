module AdminPagesControllerExtension
  def self.included(base)
    base.before_filter :attach_css
  end

  def attach_css
    include_stylesheet 'admin/user_page'
  end
end
