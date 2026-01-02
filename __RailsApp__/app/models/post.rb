class Post < ApplicationRecord
  belongs_to :author
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
end
