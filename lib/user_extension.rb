module UserExtension
  def self.included(base)
    base.has_many :permissions, :class_name => 'UserPagePermission'
  end

  def can?(action, page)
    UserPagePermission.count(:conditions => ['user_id = ? AND page_id = ? AND action = ?', self.id, page.id, action.to_s]) > 0
  end
end
