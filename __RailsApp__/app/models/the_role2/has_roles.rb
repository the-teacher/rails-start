# frozen_string_literal: true

# Adds role management to any model (User, Company, Profile, etc.)
#
# Features:
# - Many roles through RoleAssignment
# - One current (active) role stored in current_role_id
# - Role switching with validation
# - In-memory permission checking
#
module TheRole2
  module HasRoles
    extend ActiveSupport::Concern

    included do
      has_many :role_assignments,
               as: :holder,
               class_name: "TheRole2::RoleAssignment",
               dependent: :destroy

      has_many :roles,
               through: :role_assignments,
               source: :role,
               class_name: "TheRole2::Role"

      belongs_to :current_role,
                 class_name: "TheRole2::Role",
                 optional: true

      validate :current_role_must_be_assigned, if: :current_role_id?
    end

    # Returns all roles assigned to the holder
    def available_roles
      roles.distinct
    end

    # Assign a new role (optionally set it as current)
    def assign_role!(role, make_current: false)
      role = TheRole2::Role.find(role) if role.is_a?(Integer)
      role_assignments.find_or_create_by!(role: role)
      switch_role!(role) if make_current
      role
    end

    # Switch the active role (must already be assigned)
    def switch_role!(role)
      role = TheRole2::Role.find(role) if role.is_a?(Integer)
      unless roles.exists?(role.id)
        raise ActiveRecord::RecordInvalid, "#{self.class.name} does not have role #{role.name}"
      end
      update!(current_role: role)
    end

    # Remove a role; clear current_role if it was active
    def remove_role!(role)
      role = TheRole2::Role.find(role) if role.is_a?(Integer)
      role_assignments.where(role: role).destroy_all
      update!(current_role: nil) if current_role == role
    end

    # Preload permissions of the current role
    def preload_permissions!
      current_role&.permissions_preload!
    end

    # Main permission check
    def has_permission?(key)
      current_role&.permission_allowed?(key) || false
    end

    private

    # Validation: current_role must belong to assigned roles
    def current_role_must_be_assigned
      unless roles.exists?(current_role_id)
        errors.add(:current_role, "must be one of assigned roles")
      end
    end
  end
end
