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
    before_validation :set_actor_from_thread_local, on: :create

    # Thread-local actor reference (set per request or console session)
    thread_mattr_accessor :current_actor
    thread_mattr_accessor :disable_logging

    # Logging control methods
    def self.disable_logging!
      warn "[TheRole2::PermissionLog] Logging is now DISABLED"
      self.disable_logging = true
      false
    end

    def self.enable_logging!
      warn "[TheRole2::PermissionLog] Logging is now ENABLED"
      self.disable_logging = false
      true
    end

    def self.logging_status
      disable_logging ? "DISABLED" : "ENABLED"
    end

    # Centralized log creation method
    def self.create_log!(**attrs)
      return if disable_logging
      create!(**attrs)
    end

    private

    # Set actor from thread-local variable (required)
    def set_actor_from_thread_local
      return if self.class.disable_logging

      current_actor = TheRole2::PermissionLog.current_actor
      
      if current_actor.present?
        self.actor = current_actor
      else
        errors.add(:actor, "must be set before creating a permission log")
        raise ActiveRecord::RecordInvalid, self
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
