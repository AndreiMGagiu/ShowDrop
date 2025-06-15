class TvShow < ApplicationRecord
  has_many :releases, dependent: :destroy
  has_many :distributors, through: :releases

  validates :provider_identifier, presence: true, uniqueness: true
  validates :name, presence: true
  validates :language, presence: true
end
