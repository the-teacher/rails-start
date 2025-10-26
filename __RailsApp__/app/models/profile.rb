class Profile < ApplicationRecord
  include TheRole2::HasRoles

  belongs_to :user

  validates :user_id, presence: true
end
