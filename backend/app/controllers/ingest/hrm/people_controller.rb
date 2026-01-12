module Ingest
  module Hrm
    class PeopleController < ApiController
      def create
        records = Array.wrap(params_payload)
        @people = []
        @errors = []

        records.each do |record_params|
          begin
            person = Ingest::Hrm::SavePersonService.new(record_params).call
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
        fields = [:external_id, :email, :first_name, :last_name, :job_title, :department, :manager_email, :start_date, :updated_at]
        if params[:_json]
          params.permit(_json: fields)[:_json]
        else
          params.permit(*fields)
        end
      end
    end
  end
end
