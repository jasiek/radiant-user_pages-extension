module UserExtension
  def self.included(base)
    base.has_many :permissions, :class_name => 'UserPagePermission'
  end

  def can?(action, page)
    admin? || permissions.count(:conditions => ['page_id = ? AND action = ?', page.id, action.to_s]) > 0
  end
end
