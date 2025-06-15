require 'rails_helper'

RSpec.describe TvShowService::StoreBroadcastData do
  subject(:store_service) { described_class.new(episode_data) }

  let(:episode_data) do
    {
      'id' => 123,
      'name' => 'Test Episode',
      'airdate' => '2025-08-15',
      'airstamp' => '2025-08-15T20:00:00Z',
      'runtime' => 60,
      'season' => 2,
      'number' => 3,
      'show' => {
        'id' => 999,
        'name' => 'Test Show',
        'premiered' => '2013-06-03',
        'language' => 'English',
        'status' => 'Running',
        'rating' => { 'average' => 8.4 },
        'summary' => 'A very good show.',
        'image' => { 'medium' => 'http://example.com/show.jpg' },
        'network' => {
          'name' => 'Test Network',
          'country' => { 'name' => 'USA' },
          'type' => 'network'
        }
      }
    }
  end

  describe '#call' do
    context 'with valid data' do
      it 'creates TvShow, Distributor, and Release records' do
        expect { store_service.call }
          .to change(TvShow, :count).by(1)
          .and change(Distributor, :count).by(1)
          .and change(Release, :count).by(1)
      end
    end

    context 'when TvShow already exists' do
      before { create(:tv_show, provider_identifier: 999) }

      it 'does not create a new TvShow' do
        expect { store_service.call }.not_to change(TvShow, :count)
      end
    end

    context 'when Distributor already exists' do
      before { create(:distributor, name: 'Test Network') }

      it 'does not create a new Distributor' do
        expect { store_service.call }.not_to change(Distributor, :count)
      end
    end

    context 'when Release already exists' do
      let!(:tv_show) { create(:tv_show, provider_identifier: 999) }
      let!(:distributor) { create(:distributor, name: 'Test Network') }

      before do
        create(:release, episode_id: 123, tv_show: tv_show, distributor: distributor)
      end

      it 'does not create a new Release' do
        expect { store_service.call }.not_to change(Release, :count)
      end
    end

    context 'when show data is missing' do
      before { episode_data.delete('show') }

      it 'does not create a TvShow' do
        expect { store_service.call }.not_to change(TvShow, :count)
      end
    end

    context 'when upsert raises an exception' do
      before do
        allow(TvShow).to receive(:upsert).and_raise(ActiveRecord::RecordInvalid.new(TvShow.new))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error' do
        store_service.call
        expect(Rails.logger).to have_received(:error).with(
          hash_including(message: 'Episode import failure', episode_id: 123)
        )
      end

      it 'does not raise the error' do
        expect { store_service.call }.not_to raise_error
      end
    end
  end
end
