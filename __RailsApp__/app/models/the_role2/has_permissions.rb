# frozen_string_literal: true

# Adds permission management to any model (User, Company, Profile, etc.)
#
# Features:
# - Direct permissions via polymorphic holder relationship
# - Check permissions on the model itself
# - In-memory permission caching with automatic invalidation
# - Efficient cache updates on permission changes
#
# Available Methods:
# - preload_permissions!           — Load permissions into memory for fast checking
# - permissions_hash               — Get cached permissions (auto-loads if needed)
# - reload_permissions!            — Clear and reload permission cache
# - has_permission?(key)           — Check if model has a permission using compound key
# - delete_permission!(key)        — Delete a permission entirely
# - enable_permission!(key)        — Re-enable a previously disabled permission
# - disable_permission!(key)       — Disable a permission (keep but don't apply)
#
# Usage:
#   class User < ApplicationRecord
#     include TheRole2::HasPermissions
#   end
#
#   user = User.first
#   user.permissions.create!(resource: 'posts', action: 'create', scope: nil, value: true)
#   user.preload_permissions!
#   user.has_permission?('posts::create')        # => true
#
#   user.disable_permission!('posts::create')    # disables + updates cache
#   user.has_permission?('posts::create')        # => false
#
#   user.enable_permission!('posts::create')     # enables + updates cache
#   user.has_permission?('posts::create')        # => true
#

module TheRole2
  module HasPermissions
    extend ActiveSupport::Concern

    included do
      has_many :permissions,
               as: :holder,
               class_name: "TheRole2::Permission",
               dependent: :destroy

      # Cached permissions hash for preload
      attr_reader :_permission_cache
    end

    # Delete a permission from this holder and clear cache
    def delete_permission!(key)
      permission_by_key(key).destroy_all
      reload_permission_cache!
    end

    # Enable a permission and update cache
    def enable_permission!(key)
      permission = permission_by_key(key).take!
      permission.update!(enabled: true)
      update_permission_cache!(key, permission)
    end

    # Disable a permission (keep it but don't apply it) and update cache
    def disable_permission!(key)
      permission = permission_by_key(key).take!
      permission.update!(enabled: false)
      remove_permission_from_cache!(key)
    end

    # Load all effective permissions into memory cache for fast lookup
    def preload_permissions!
      return @_permission_cache if @_permission_cache.present?

      @_permission_cache = permissions.effective.each_with_object({}) do |perm, hash|
        key = build_permission_key(perm.scope, perm.resource, perm.action)
        hash[key] = perm.value
      end
    end

    # Get cached permissions hash, auto-loading if needed
    def permissions_hash
      @_permission_cache ? @_permission_cache : preload_permissions!
    end

    # Clear and reload permission cache
    def reload_permissions!
      @_permission_cache = nil
      preload_permissions!
    end

    # Check if holder has a specific permission using compound key (e.g., "posts::create")
    def has_permission?(key)
      normalized_key = normalize_key(key)
      if @_permission_cache.present?
        @_permission_cache[normalized_key] || false
      else
        permissions.effective.by_key(normalized_key).exists?
      end
    end

    private

    # Parse and normalize permission key from compound format
    def normalize_key(key)
      scope, resource, action = TheRole2::Permission.parse_key(key)
      build_permission_key(scope, resource, action)
    end

    # Build compound key from scope, resource, and action components
    def build_permission_key(scope, resource, action)
      [ scope, resource, action ].compact.join("::")
    end

    # Find permissions by compound key
    def permission_by_key(key)
      scope, resource, action = TheRole2::Permission.parse_key(key)
      permissions.where(scope: scope, resource: resource, action: action)
    end

    # Update specific permission in cache after enable
    def update_permission_cache!(key, permission)
      preload_permissions! unless @_permission_cache
      normalized_key = normalize_key(key)
      @_permission_cache[normalized_key] = permission.value if permission.enabled?
    end

    # Remove specific permission from cache after disable
    def remove_permission_from_cache!(key)
      return unless @_permission_cache
      normalized_key = normalize_key(key)
      @_permission_cache.delete(normalized_key)
    end
  end
end
