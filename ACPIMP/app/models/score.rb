class Score < ApplicationRecord
  belongs_to :registration
  belongs_to :user
  belongs_to :score_category

  has_one_attached :comment_file
end
