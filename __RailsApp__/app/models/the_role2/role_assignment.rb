module TheRole2
  class RoleAssignment < ApplicationRecord
    self.table_name = "the_role2_role_assignments"

    belongs_to :role, class_name: "TheRole2::Role", foreign_key: "the_role2_role_id"
    belongs_to :holder, polymorphic: true

    validates :role_id, presence: true
  end
end
