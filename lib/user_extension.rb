module UserExtension
  def self.included(base)
    base.has_many :permissions, :class_name => 'UserPagePermission'
  end

  # Does this user have the necessary priviledges to execute a given action?
  def can?(action, page)
    permissions.count(:conditions => ['page_id = ? AND action = ?', page.id, action.to_s]) > 0
  end
end
