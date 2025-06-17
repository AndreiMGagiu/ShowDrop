# frozen_string_literal: true

# Builds a filtered scope for TV shows, based on optional params.
#
# Supports filtering by:
# - premiere date range (`date_from` and `date_to`)
# - minimum rating (`min_rating`)
# - language (`language`)
# - distributor name (`distributor`)
# - distributor country (`country`)
#
# Example usage:
#   TvShowQuery.new(TvShow.all, params).call
#
class TvShowQuery
  # Initializes a new TvShowQuery
  #
  # @param scope [ActiveRecord::Relation] base scope to filter (default: TvShow.all)
  # @param params [Hash] filter parameters (typically from controller `params`)
  def initialize(scope = TvShow.all, params = {})
    @scope = scope
    @params = params
  end

  # Applies filters to the scope based on presence of params
  #
  # @return [ActiveRecord::Relation] filtered ActiveRecord relation of TvShow
  def call
    filtered_scope = filter_by_date_range(@scope)
    filtered_scope = filter_by_rating(filtered_scope)
    filtered_scope = filter_by_language(filtered_scope)

    if params[:distributor].present? || params[:country].present?
      filtered_scope = filtered_scope.joins(:distributors)
      filtered_scope = filter_by_distributor(filtered_scope)
      filtered_scope = filter_by_country(filtered_scope)
    end

    filtered_scope.includes(releases: :distributor).order(:name, :id).distinct
  end

  private

  # @return [Hash] filter params
  attr_reader :params

  # Filters the scope by premiere date range if present
  #
  # @param scope [ActiveRecord::Relation] current scope
  # @return [ActiveRecord::Relation] scope filtered by premiered date range
  def filter_by_date_range(scope)
    return scope unless params[:date_from].present? || params[:date_to].present?

    scope.where(premiered: date_from..date_to)
  end

  # Filters the scope by minimum rating if present
  #
  # @param scope [ActiveRecord::Relation] current scope
  # @return [ActiveRecord::Relation] scope filtered by rating >= min_rating
  def filter_by_rating(scope)
    return scope if params[:min_rating].blank?

    scope.where(rating: params[:min_rating].to_f..)
  end

  # Filters the scope by language if present
  #
  # @param scope [ActiveRecord::Relation] current scope
  # @return [ActiveRecord::Relation] scope filtered by language
  def filter_by_language(scope)
    return scope if params[:language].blank?

    scope.where(language: params[:language])
  end

  # Filters the scope by distributor name if present
  #
  # @param scope [ActiveRecord::Relation] current scope
  # @return [ActiveRecord::Relation] scope filtered by distributor name
  def filter_by_distributor(scope)
    return scope if params[:distributor].blank?

    scope.where(distributors: { name: params[:distributor] })
  end

  # Filters the scope by distributor country if present
  #
  # @param scope [ActiveRecord::Relation] current scope
  # @return [ActiveRecord::Relation] scope filtered by distributor country
  def filter_by_country(scope)
    return scope if params[:country].blank?

    scope.where(distributors: { country: params[:country] })
  end

  # Parses the date_from param or returns a fallback date
  #
  # @return [Date] starting date for filtering
  def date_from
    Date.parse(params[:date_from])
  rescue StandardError
    Date.new(1970, 1, 1)
  end

  # Parses the date_to param or returns a fallback date
  #
  # @return [Date] ending date for filtering
  def date_to
    Date.parse(params[:date_to])
  rescue StandardError
    Time.zone.today
  end
end
