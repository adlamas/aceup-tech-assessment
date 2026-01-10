module Api
  module V1
    class ApiController < ApplicationController
      include Pagy::Method
      before_action :ensure_json_request

      rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

      private

      def ensure_json_request
        request.format = :json
      end

      def render_record_not_found(exception)
        logger.info(exception)
        render json: { errors: exception.message }, status: :not_found
      end

      def render_record_invalid(exception)
        logger.info(exception)
        render json: { error: exception.message }, status: :unprocessable_entity
      end
    end
  end
end
