module TheRole2
  class Permission < ApplicationRecord
    self.table_name = "the_role2_permissions"

    belongs_to :holder, polymorphic: true
    has_many :logs, class_name: "TheRole2::PermissionLog", dependent: :destroy

    validates :resource, presence: true
    validates :action, presence: true
    validates :value, inclusion: { in: [ true, false ] }

    # Automatically normalize identifiers (lowercase, underscores)
    normalizes :scope, :resource, :action, with: TheRole2::KeyNormalizer

    # --- scopes ---
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

    # --- automatic logging ---
    after_create  -> { log_action!(:create) }
    after_update  -> { log_action!(:update) }
    after_destroy -> { log_action!(:delete) }

    # --- helpers ---
    def full_key
      [ scope, resource, action ].compact.join("::")
    end

    def title
      full_key
    end

    def effective?
      enabled? && within_time_window?
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
      raise "TheRole2::PermissionLog.actor is not set" if actor.blank?

      TheRole2::PermissionLog.create!(
        permission: self,
        actor: actor,
        action: action
      )
    end
  end
end
