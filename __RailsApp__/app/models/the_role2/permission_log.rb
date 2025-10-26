module TheRole2
  class PermissionLog < ApplicationRecord
    self.table_name = "the_role2_permission_logs"

    belongs_to :permission, class_name: "TheRole2::Permission", foreign_key: "permission_id"
    belongs_to :actor, polymorphic: true

    enum :action, {
      create: "create",
      update: "update",
      delete: "delete"
    }, prefix: true

    before_create :snapshot_permission
    before_create :set_actor_from_thread_local

    # Thread-local actor reference (set per request or console session)
    thread_mattr_accessor :actor

    private

    # Set actor from thread-local variable (required)
    def set_actor_from_thread_local
      actor = TheRole2::PermissionLog.actor

      if actor.present?
        # TODO: Check why polymorphic assignment does not work directly
        # For polymorphic association, we need to set both id and type
        self.actor_id = actor.id
        self.actor_type = actor.class.name
      else
        raise "TheRole2::PermissionLog.actor must be set before creating a permission log"
      end
    end

    # Capture a snapshot of the permission at the moment of change
    def snapshot_permission
      self.snapshot = permission.slice(
        "enabled",
        "scope",
        "resource",
        "action",
        "description",
        "value",
        "starts_at",
        "ends_at",
      )
    end
  end
end
