module TheRole2
  class PermissionLog < ApplicationRecord
    self.table_name = "the_role2_permission_logs"

    belongs_to :permission, class_name: "TheRole2::Permission", foreign_key: "permission_id"
    belongs_to :actor, polymorphic: true

    enum :action, { create: "create", update: "update", delete: "delete" }

    before_create :snapshot_permission

    # Thread-local actor reference (set per request or console session)
    thread_mattr_accessor :actor

    private

    # Capture a snapshot of the permission at the moment of change
    def snapshot_permission
      self.snapshot = permission.slice(
        "scope", "resource", "action", "value",
        "enabled", "starts_at", "ends_at", "description"
      )
    end
  end
end
