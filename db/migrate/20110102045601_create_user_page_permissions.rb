class CreateUserPagePermissions < ActiveRecord::Migration
  def self.up
    create_table :user_page_permissions do |t|
      t.integer :user_id
      t.integer :page_id
      t.string :permission
      t.timestamps
    end
  end

  def self.down
    drop_table :user_page_permissions
  end
end
