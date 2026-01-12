require 'rails_helper'

RSpec.describe "Ingest::Hrm::People", type: :request do
  # Bypass middleware for Docker/Host issues
  before { host! "127.0.0.1" }

  describe "POST /ingest/hrm/people" do
    let(:valid_headers) { { "Content-Type" => "application/json" } }

    context "when sending a single person" do
      let(:hrm_payload) do
        {
          external_id: "HRM-5001",
          email: "pam.beesly@dundermifflin.com",
          first_name: "Pam",
          last_name: "Beesly",
          job_title: "Receptionist",
          department: "Administration",
          manager_email: "m.scott@dundermifflin.com",
          start_date: "2023-05-10",
          updated_at: Time.current.change(usec: 0)
        }
      end

      it "creates a new person and a new HRM identity with correct attributes" do
        expect {
          post "/ingest/hrm/people", params: hrm_payload.to_json, headers: valid_headers
        }.to change(Person, :count).by(1).and change(ExternalIdentity, :count).by(1)

        expect(response).to have_http_status(:ok)

        # Verify attributes in database
        person = Person.last
        identity = person.external_identities.find_by(source: 'hrm')

        expect(person.first_name).to eq("Pam")
        expect(identity.department).to eq("Administration")
        expect(identity.metadata["job_title"]).to eq("Receptionist")
        expect(identity.metadata["manager_email"]).to eq("m.scott@dundermifflin.com")
      end
    end

    context "when sending a batch of people" do
      let(:batch_payload) do
        [
          {
            external_id: "HRM-B1",
            email: "jim@dundermifflin.com",
            first_name: "Jim",
            last_name: "Halpert",
            department: "Sales",
            updated_at: Time.current
          },
          {
            external_id: "HRM-B2",
            email: "dwight@dundermifflin.com",
            first_name: "Dwight",
            last_name: "Schrute",
            department: "Sales",
            updated_at: Time.current
          }
        ]
      end

      it "creates multiple records and returns a success status" do
        expect {
          post "/ingest/hrm/people", params: batch_payload.to_json, headers: valid_headers
        }.to change(Person, :count).by(2)

        expect(json_response[:status]).to eq('success')
        expect(json_response[:people].size).to eq(2)
      end
    end

    context "when a record fails in a batch" do
      let(:mixed_payload) do
        [
          {
            external_id: "HRM-OK",
            email: "ok@example.com",
            first_name: "Valid",
            last_name: "User"
          },
          {
            external_id: "HRM-FAIL",
            email: "invalid-email", # This should trigger a validation error if you have one
            first_name: nil # This should trigger a DB null constraint error
          }
        ]
      end

      it "returns a multi_status (207) and lists the errors" do
        post "/ingest/hrm/people", params: mixed_payload.to_json, headers: valid_headers

        expect(response).to have_http_status(:multi_status)
        expect(json_response[:status]).to eq('partial_success')
        expect(json_response[:errors].first[:external_id]).to eq("HRM-FAIL")
        expect(json_response[:errors].first[:message]).to be_present
      end
    end

    context "when deduplicating against an existing CRM record" do
      let!(:existing_person) { Person.create!(first_name: "John", last_name: "Doe") }
      let!(:crm_identity) do
        ExternalIdentity.create!(
          person: existing_person,
          source: 'crm',
          external_id: 'CRM-101',
          email: 'john.doe@example.com',
          department: 'Sales'
        )
      end

      let(:hrm_payload) do
        {
          external_id: "HRM-9001",
          email: "john.doe@example.com", # Same email
          first_name: "John",
          last_name: "Doe",
          department: "Engineering"
        }
      end

      it "does not create a new person and links the HRM identity to the existing one" do
        expect {
          post "/ingest/hrm/people", params: hrm_payload.to_json, headers: valid_headers
        }.to change(ExternalIdentity, :count).by(1).and change(Person, :count).by(0)

        expect(existing_person.external_identities.count).to eq(2)
        
        # Verify HRM department is correctly set (Source of Truth)
        hrm_identity = existing_person.external_identities.find_by(source: 'hrm')
        expect(hrm_identity.department).to eq("Engineering")
      end
    end
  end
end
