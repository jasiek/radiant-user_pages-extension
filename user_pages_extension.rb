class UserPagesExtension < Radiant::Extension
  version "1.0"
  description "Controls page manipulation operations (create, update, destroy) on a per-user basis."
  url "http://github.com/jasiek/radiant-user_pages-extension"

  extension_config do |config|
    config.active_record.observers = [config.active_record.observers, :page_observer, :user_page_permission_observer]
  end
  
  def activate
    PageObserver.instance.send(:add_observer!, Page)
    UserPagePermissionObserver.instance.send(:add_observer!, UserPagePermission)
    Page.send(:include, PageExtension)
    User.send(:include, UserExtension)
    Admin::PagesController.send(:include, AdminPagesControllerExtension)
    Admin::PagesController.send(:helper, AdminPagesHelperExtension)
    ApplicationController.class_eval do
      def set_current_user
        PageObserver.current_user = UserPagePermissionObserver.current_user = UserActionObserver.current_user = current_user
      end
    end
    admin.page.edit.add :parts_bottom, 'page_permissions', :after => 'edit_timestamp'
  end

  class AccessDenied < StandardError; end
end
