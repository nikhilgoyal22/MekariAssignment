class Employee < ApplicationRecord
  belongs_to :company
  belongs_to :parent, class_name: 'Employee', optional: true
  has_and_belongs_to_many :policies

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates_numericality_of :phone, integer_only: true, greater_than: 0, allow_nil: true
  # acts_as_nested_set
end
