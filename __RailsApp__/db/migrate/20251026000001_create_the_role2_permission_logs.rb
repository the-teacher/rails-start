class CreateTheRole2PermissionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :the_role2_permission_logs do |t|
      t.references :permission, null: false
      t.references :actor, polymorphic: true, null: false

      # Action type (create / update / delete)
      t.string :action, null: false

      # JSON snapshot of the permission at the time of the action
      # Use jsonb for PostgreSQL, json for others
      snapshot_type = connection.adapter_name.downcase.include?('postgres') ? :jsonb : :json
      t.column :snapshot, snapshot_type, default: {}

      # Optional note or reason for the change
      t.text   :note

      t.timestamps
    end
  end
end
