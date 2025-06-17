# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Distributor, type: :model do
  subject(:distributor) { build(:distributor) }

  describe 'associations' do
    it { is_expected.to have_many(:releases).dependent(:destroy) }
    it { is_expected.to have_many(:tv_shows).through(:releases) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    context 'when name is missing' do
      before { distributor.name = nil }

      it 'is invalid' do
        expect(distributor).not_to be_valid
      end
    end

    context 'when name and country combination is not unique' do
      before do
        create(:distributor, name: 'HBO', country: 'US')
        distributor.name = 'HBO'
        distributor.country = 'US'
      end

      it 'is invalid' do
        expect(distributor).not_to be_valid
      end
    end
  end
end
