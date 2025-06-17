# frozen_string_literal: true

# ImportTvShowsJob is a Sidekiq job that runs daily to import
# upcoming TV show data.
class ImportTvShowsJob
  include Sidekiq::Job
  sidekiq_options queue: 'import-tv-shows'

  # Executes the job to import TV shows from the TVMaze API.
  #
  # @return [void]
  def perform
    TvShowService::Importer.new.call
  end
end
