
module Ingest
  module Crm
    class PeopleController < ApiController
      def create
        records = Array.wrap(params_payload)
        @people = []
        @errors = []

        records.each do |record_params|
          begin
            person = Ingest::Crm::SavePersonService.new(record_params).call
            
            @people << { person: person, external_id: record_params[:external_id] }
          rescue StandardError => e
            @errors << { external_id: record_params[:external_id], message: e.message }
          end
        end

        status = @errors.any? ? :multi_status : :ok
        render :create, status: status
      end

      private

      def params_payload
        if params[:_json]
          params.permit(_json: [:external_id, :email, :first_name, :last_name, :phone, :company, :updated_at])[:_json]
        else
          params.permit(:external_id, :email, :first_name, :last_name, :phone, :company, :updated_at)
        end
      end
    end
  end
end
