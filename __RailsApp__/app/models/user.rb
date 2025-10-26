class User < ApplicationRecord
  include TheRole2::HasRoles

  has_many :profiles, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :departments, through: :employees
  has_many :students, foreign_key: "user_id", dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
