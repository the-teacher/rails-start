class Department < ApplicationRecord
  belongs_to :company
  has_many :employees, dependent: :destroy
  has_many :users, through: :employees

  validates :name, presence: true
  validates :company_id, presence: true
end
