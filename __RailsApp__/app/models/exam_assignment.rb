class ExamAssignment < ApplicationRecord
  belongs_to :student
  belongs_to :exam

  validates :student_id, presence: true
  validates :exam_id, presence: true
  validates :student_id, uniqueness: { scope: :exam_id, message: "can only be assigned to an exam once" }
end
