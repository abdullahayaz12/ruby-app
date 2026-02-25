class Widget < ActiveRecord::Base
  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
