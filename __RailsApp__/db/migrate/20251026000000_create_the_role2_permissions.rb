class CreateTheRole2Permissions < ActiveRecord::Migration[8.1]
  def change
    create_table :the_role2_permissions do |t|
      t.references :holder, polymorphic: true, null: false

      # title is: "scope:resource:action" e.g. "blog:articles:create"

      # Optional human-readable description
      t.text :description

      # Whether the rule is currently enabled
      t.boolean :enabled, null: false, default: true

      # Definition of a scope for the permission
      t.string  :scope                      # forum, project, global, etc. or nil
      t.string  :resource, null: false      # resource type (e.g., "articles", "comments")
      t.string  :action,   null: false      # action type (e.g., "index", "create", "update", "edit", "delete")

      # Allow or deny
      t.boolean :value,    null: false, default: true

      # Time-based activation window
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end

    add_index :the_role2_permissions,
      [ :holder_type, :holder_id, :scope, :resource, :action ],
      unique: true,
      name: "idx_the_role2_permissions_holder_scope_resource_action"
  end
end
