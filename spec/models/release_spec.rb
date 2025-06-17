# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release, type: :model do
  subject(:release) { build(:release) }

  describe 'associations' do
    it { is_expected.to belong_to(:tv_show) }
    it { is_expected.to belong_to(:distributor) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:episode_id) }
    it { is_expected.to validate_uniqueness_of(:episode_id) }

    context 'when episode_id is missing' do
      before { release.episode_id = nil }

      it 'is invalid' do
        expect(release).not_to be_valid
      end
    end

    context 'when episode_id is not unique' do
      before do
        create(:release, episode_id: 99_999)
        release.episode_id = 99_999
      end

      it 'is invalid' do
        expect(release).not_to be_valid
      end
    end
  end
end
