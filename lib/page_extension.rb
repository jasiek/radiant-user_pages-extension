module PageExtension
  def self.included(base)
    base.has_many :permissions, :class_name => 'UserPagePermission'
  end

  def children
    Page.find(:all, :conditions => ['parent_id = ?', self.id])
  end
end
