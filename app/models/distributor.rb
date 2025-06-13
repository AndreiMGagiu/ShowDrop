class Distributor < ApplicationRecord
  has_many :releases, dependent: :destroy
  has_many :tv_shows, through: :releases

  validates :name, presence: true, uniqueness: { scope: :country }
end
