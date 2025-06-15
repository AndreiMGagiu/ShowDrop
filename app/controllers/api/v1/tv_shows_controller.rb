# frozen_string_literal: true

module Api
  module V1
    class TvShowsController < ApplicationController
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

      def show
        render json: TvShowsSerializer.new(tv_show).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TV show not found' }, status: :not_found
      end

      private

      def tv_show
        @tv_show ||= filtered_scope.find_by!(id: params[:id])
      end

      def filtered_scope
        TvShowQuery.new(TvShow.all, params).call
      end
    end
  end
end
