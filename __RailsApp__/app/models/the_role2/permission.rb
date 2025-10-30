module TheRole2
  # Permission model for TheRole2 RBAC system
  #
  # Represents a permission that can be assigned to roles or models directly.
  # Supports scopes, time-based activation, and audit logging.
  #
  # Available Methods:
  # - full_key              - Returns "scope::resource::action" string
  # - title                 - Alias for full_key
  # - effective?            - Check if permission is enabled and within time window
  # - enable!               - Enable permission (set enabled: true)
  # - disable!              - Disable permission (set enabled: false)
  # - on!                   - Grant permission (set value: true)
  # - off!                  - Deny permission (set value: false)
  #
  # Class Methods:
  # - parse_key(key)        - Parse "scope::resource::action" into components [scope, resource, action]
  #
  # Scopes:
  # - enabled               - Only enabled permissions
  # - effective             - Enabled + within time window
  # - by_key(key)           - Find by compound key
  #
  class Permission < ApplicationRecord
    self.table_name = "the_role2_permissions"

    belongs_to :holder, polymorphic: true
    has_many :logs, class_name: "TheRole2::PermissionLog", dependent: :destroy

    validates :resource, presence: true
    validates :action, presence: true
    validates :value, inclusion: { in: [ true, false ] }

    # Automatically normalize identifiers (lowercase, underscores)
    normalizes :scope, :resource, :action, with: TheRole2::KeyNormalizer

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # SCOPES
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    scope :enabled, -> { where(enabled: true) }
    scope :effective, -> {
      enabled
        .where("starts_at IS NULL OR starts_at <= ?", Time.current)
        .where("ends_at IS NULL OR ends_at >= ?", Time.current)
    }

    scope :by_key, ->(key) do
      scope_name, resource_name, action_name = parse_key(key)

      if scope_name && resource_name && action_name
        where(scope: scope_name, resource: resource_name, action: action_name)
      elsif resource_name && action_name
        where(resource: resource_name, action: action_name)
          .where(scope: [ nil, "" ])
      else
        none
      end
    end

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # LOGGING
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    after_create  -> { log_action!(:create) }
    after_update  -> { log_action!(:update) }
    after_destroy -> { log_action!(:delete) }

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # HELPER METHODS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    def full_key
      [ scope, resource, action ].compact.join("::")
    end

    def title
      full_key
    end

    def effective?
      enabled? && within_time_window?
    end

    def enable!
      update!(enabled: true)
    end

    def disable!
      update!(enabled: false)
    end

    def on!
      update!(value: true)
    end

    def off!
      update!(value: false)
    end

    def self.parse_key(key)
      parts = key.to_s.split("::").map { |v| TheRole2::KeyNormalizer.call(v) }
      case parts.size
      when 3 then parts
      when 2 then [ nil, *parts ]
      else [ nil, nil, nil ]
      end
    end

    private

    def within_time_window?
      (starts_at.nil? || starts_at <= Time.current) &&
        (ends_at.nil? || ends_at >= Time.current)
    end

    # Log each permission change and ensure actor is defined
    def log_action!(action)
      actor = TheRole2::PermissionLog.actor

      # Skip logging if no actor is set
      return if actor.blank?

      TheRole2::PermissionLog.create!(
        permission: self,
        actor: actor,
        action: action
      )
    end
  end
end
