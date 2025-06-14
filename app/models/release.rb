class Release < ApplicationRecord
  belongs_to :tv_show
  belongs_to :distributor

  validates :episode_id, presence: true, uniqueness: true
end
