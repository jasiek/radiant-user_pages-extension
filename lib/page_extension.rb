module PageExtension
  def self.included(base)
    base.has_many :permissions, :class_name => 'UserPagePermission'
  end
end
