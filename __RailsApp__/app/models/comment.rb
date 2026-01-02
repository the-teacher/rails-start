class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author

  validates :body, presence: true
end
