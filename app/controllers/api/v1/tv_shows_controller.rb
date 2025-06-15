# frozen_string_literal: true

module Api
  module V1
    # Controller for managing TV show data via the API.
    #
    # Supports:
    # - Listing TV shows with filters and pagination
    # - Retrieving a single TV show by ID
    #
    # Uses:
    # - TvShowQuery for filtering logic
    # - TvShowsSerializer for structured JSON output
    class TvShowsController < ApplicationController
      # GET /api/v1/tv_shows
      #
      # Lists TV shows with optional filters and pagination.
      #
      # Query Params:
      # @option params [String] :date_from (optional) Filter by premiere start date
      # @option params [String] :date_to (optional) Filter by premiere end date
      # @option params [Float]  :min_rating (optional) Minimum average rating
      # @option params [String] :language (optional) Filter by language
      # @option params [String] :distributor (optional) Filter by distributor name
      # @option params [String] :country (optional) Filter by distributor country
      #
      # @return [JSON] Serialized list of TV shows with pagination metadata
      def index
        pagy, records = pagy(filtered_scope)
        render json: {
          data: TvShowsSerializer.collection(records),
          pagination: {
            page: pagy.page,
            items: pagy.vars[:items],
            pages: pagy.pages,
            count: pagy.count
          }
        }, status: :ok
      end

      # GET /api/v1/tv_shows/:id
      #
      # Retrieves a single TV show by its UUID.
      #
      # @return [JSON] Serialized TV show data
      # @raise [ActiveRecord::RecordNotFound] if no TV show with given ID exists
      def show
        render json: TvShowsSerializer.new(tv_show).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TV show not found' }, status: :not_found
      end

      private

      # Finds the requested TV show by ID within the filtered scope
      #
      # @return [TvShow]
      def tv_show
        @tv_show ||= filtered_scope.find_by!(id: params[:id])
      end

      # Applies filtering to the base TV show scope using TvShowQuery
      #
      # @return [ActiveRecord::Relation]
      def filtered_scope
        TvShowQuery.new(TvShow.all, params).call
      end
    end
  end
end
