require 'rails_helper'

RSpec.describe "Ingest::Crm::People", type: :request do
  before { host! "127.0.0.1" }

  describe "POST /ingest/crm/people" do
    let(:valid_headers) { { "Content-Type" => "application/json" } }

    context "when sending a single person" do
      let(:single_payload) do
        {
          external_id: "CRM-101",
          email: "single@example.com",
          first_name: "Single",
          last_name: "Record",
          phone: "123456",
          company: "Solo Corp",
          updated_at: Time.current.change(usec: 0)
        }
      end

      it "creates a new person and a new external identity with correct attributes" do
        expect {
          post "/ingest/crm/people", params: single_payload.to_json, headers: valid_headers
        }.to change(Person, :count).by(1).and change(ExternalIdentity, :count).by(1)

        # Verify Person attributes
        person = Person.last
        expect(person.first_name).to eq(single_payload[:first_name])
        expect(person.last_name).to eq(single_payload[:last_name])

        # Verify ExternalIdentity attributes
        identity = person.external_identities.find_by(source: 'crm')
        expect(identity.external_id).to eq(single_payload[:external_id])
        expect(identity.email).to eq(single_payload[:email])
        expect(identity.metadata["phone"]).to eq(single_payload[:phone])
        expect(identity.metadata["company"]).to eq(single_payload[:company])
      end

      it "is idempotent (does not create duplicate on re-send)" do
        post "/ingest/crm/people", params: single_payload.to_json, headers: valid_headers
        
        expect {
          post "/ingest/crm/people", params: single_payload.to_json, headers: valid_headers
        }.not_to change(Person, :count)
      end
    end

    context "when sending a batch of people" do
      let(:batch_payload) do
        [
          {
            external_id: "CRM-B1",
            email: "b1@example.com",
            first_name: "Batch",
            last_name: "One",
            updated_at: Time.current
          },
          {
            external_id: "CRM-B2",
            email: "b2@example.com",
            first_name: "Batch",
            last_name: "Two",
            updated_at: Time.current
          }
        ]
      end

      it "creates multiple people and identities with correct attributes" do
        expect {
          post "/ingest/crm/people", params: batch_payload.to_json, headers: valid_headers
        }.to change(Person, :count).by(2).and change(ExternalIdentity, :count).by(2)

        # Verify each record in the batch
        batch_payload.each do |data|
          identity = ExternalIdentity.find_by(external_id: data[:external_id], source: 'crm')
          expect(identity).to be_present
          expect(identity.person.first_name).to eq(data[:first_name])
          expect(identity.email).to eq(data[:email])
        end
      end
    end

    context "when deduplicating (linking to existing person via email)" do
      let!(:existing_person) { Person.create!(first_name: "Existing", last_name: "User") }
      let!(:hrm_identity) do
        ExternalIdentity.create!(
          person: existing_person,
          source: 'hrm',
          external_id: 'HRM-001',
          email: 'shared@example.com'
        )
      end

      let(:crm_payload) do
        {
          external_id: "CRM-999",
          email: "shared@example.com",
          first_name: "Existing",
          last_name: "User Updated",
          updated_at: Time.current
        }
      end

      it "links the new CRM identity to the existing Person record and updates attributes" do
        expect {
          post "/ingest/crm/people", params: crm_payload.to_json, headers: valid_headers
        }.to change(ExternalIdentity, :count).by(1).and change(Person, :count).by(0)

        new_identity = ExternalIdentity.find_by(external_id: "CRM-999")
        expect(new_identity.person_id).to eq(existing_person.id)

        # Verify that person attributes were updated (Partial update)
        existing_person.reload
        expect(existing_person.last_name).to eq("User Updated")
      end
    end

    context "when sending a mixed batch (partial success)" do
      let(:mixed_payload) do
        [
          {
            external_id: "CRM-GOOD",
            email: "good@example.com",
            first_name: "Valid",
            last_name: "Record",
            updated_at: Time.current
          },
          {
            # Missing first_name and last_name (assuming they are null: false)
            # or invalid data that would trigger an error in the service
            external_id: "CRM-BAD",
            email: "bad-email-format",
            updated_at: Time.current
          }
        ]
      end

      it "responds with multi_status and reports the specific error" do
        post "/ingest/crm/people", params: mixed_payload.to_json, headers: valid_headers

        expect(response).to have_http_status(:multi_status)
        expect(json_response[:status]).to eq('partial_success')

        expect(json_response[:people].size).to eq(1)
        expect(json_response[:people].first[:person][:first_name]).to eq("Valid")

        expect(json_response[:errors].size).to eq(1)
        expect(json_response[:errors].first[:external_id]).to eq("CRM-BAD")
      end

      it "persists the valid record even if another one in the batch fails" do
        expect {
          post "/ingest/crm/people", params: mixed_payload.to_json, headers: valid_headers
        }.to change(Person, :count).by(1)
      end
    end
  end
end