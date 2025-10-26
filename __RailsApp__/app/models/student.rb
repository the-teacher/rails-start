class Student < ApplicationRecord
  include TheRole2::HasRoles

  belongs_to :user, optional: true
  has_many :exam_assignments, dependent: :destroy
  has_many :exams, through: :exam_assignments

  validates :student_id, presence: true, uniqueness: true
end
