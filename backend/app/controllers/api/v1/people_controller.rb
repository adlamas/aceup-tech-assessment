module Api
  module V1
    class PeopleController < Api::V1::ApiController
      def index
        @people = People::FindPeopleService.new(people_params).call
      end

      private

      def people_params
        params.permit(:email, :source, :department)
      end
    end
  end
end
