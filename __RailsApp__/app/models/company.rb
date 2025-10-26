class Company < ApplicationRecord
  include TheRole2::HasRoles

  has_many :departments, dependent: :destroy
  has_many :employees, through: :departments
  has_many :users, through: :employees

  validates :name, presence: true
end
