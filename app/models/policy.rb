class Policy < ApplicationRecord
  belongs_to :company
  has_and_belongs_to_many :employees

  attr_accessor :skip

  validates :name, presence: true, unless: :skip
  validates :name, uniqueness: {scope: :company}, unless: :skip
end
