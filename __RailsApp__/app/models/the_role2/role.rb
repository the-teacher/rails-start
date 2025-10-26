module TheRole2
  class Role < ApplicationRecord
    self.table_name = "the_role2_roles"

    has_many :permissions, as: :holder, class_name: "TheRole2::Permission", dependent: :destroy
    has_many :assignments, class_name: "TheRole2::RoleAssignment", dependent: :destroy

    validates :name, presence: true, uniqueness: true

    # Cached permissions hash for preload
    attr_reader :_permission_cache

    # Preload all effective permissions in memory
    def permissions_preload!
      @_permission_cache = permissions.effective.each_with_object({}) do |perm, hash|
        key = [ perm.scope, perm.resource, perm.action ].compact.join("::")
        hash[key] = perm.value
      end
      self
    end

    # Check permission using preloaded cache or fallback to DB
    def permission_allowed?(key)
      key = normalize_key(key)
      if @_permission_cache
        @_permission_cache[key] || false
      else
        permissions.effective.by_key(key).exists?
      end
    end

    private

    def normalize_key(key)
      TheRole2::Permission.parse_key(key).compact.join("::")
    end
  end
end
