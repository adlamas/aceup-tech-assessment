module Api
  module V1
    class PeopleController < Api::V1::ApiController
      def index
        scope = People::FindPeopleService.new(people_params).call

        @pagy, @people = pagy(scope)
      end

      def show
        @person = Person.find(params[:id])
      end

      private

      def people_params
        params.permit(:email, :source, :department)
      end
    end
  end
end
