class Employee < ApplicationRecord
  belongs_to :user
  belongs_to :department

  validates :user_id, presence: true
  validates :department_id, presence: true
  validates :user_id, uniqueness: { scope: :department_id, message: "can only be an employee of a department once" }
end
