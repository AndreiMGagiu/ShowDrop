# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ImportTvShowsJob, type: :job do
  describe '#perform' do
    it 'enqueues the job' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
    end

    it 'uses the correct queue' do
      described_class.perform_async
      expect(described_class.jobs.last['queue']).to eq('import-tv-shows')
    end
  end
end
