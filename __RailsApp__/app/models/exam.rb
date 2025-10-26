class Exam < ApplicationRecord
  belongs_to :user
  has_many :exam_assignments, dependent: :destroy
  has_many :students, through: :exam_assignments

  validates :title, presence: true
  validates :user_id, presence: true
end
