# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TvShow, type: :model do
  subject(:tv_show) { build(:tv_show) }

  describe 'associations' do
    it { is_expected.to have_many(:releases).dependent(:destroy) }
    it { is_expected.to have_many(:distributors).through(:releases) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider_identifier) }
    it { is_expected.to validate_uniqueness_of(:provider_identifier) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:language) }

    context 'when provider_identifier is missing' do
      before { tv_show.provider_identifier = nil }

      it 'is invalid' do
        expect(tv_show).to be_invalid
      end
    end

    context 'when name is missing' do
      before { tv_show.name = nil }

      it 'is invalid' do
        expect(tv_show).to be_invalid
      end
    end

    context 'when language is missing' do
      before { tv_show.language = nil }

      it 'is invalid' do
        expect(tv_show).to be_invalid
      end
    end

    context 'when provider_identifier is not unique' do
      before do
        create(:tv_show, provider_identifier: 12_345)
        tv_show.provider_identifier = 12_345
      end

      it 'is invalid' do
        expect(tv_show).to be_invalid
      end
    end
  end
end
