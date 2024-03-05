class Task < ApplicationRecord
  validates :content, presence: true
end
