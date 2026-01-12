module Ingest
  module Crm
    class SavePersonService
      def initialize(params)
        @params = params
        @external_id = params[:external_id]
        @email = params[:email]
      end

      def call
        ActiveRecord::Base.transaction do
          identity = ExternalIdentity.find_or_initialize_by(
            source: 'crm',
            external_id: @external_id
          )

          if identity.new_record?
            person = find_existing_person || Person.new
            identity.person = person
          else
            person = identity.person
          end

          person.assign_attributes(
            first_name: @params[:first_name],
            last_name: @params[:last_name]
          )
          person.save!

          identity.assign_attributes(
            email: @email,
            external_updated_at: @params[:updated_at],
            metadata: @params.slice(:phone, :company)
          )
          identity.save!

          person
        end
      end

      private

      def find_existing_person
        ExternalIdentity.find_by(email: @email)&.person
      end
    end
  end
end