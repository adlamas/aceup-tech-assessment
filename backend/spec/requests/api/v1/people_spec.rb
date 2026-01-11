require 'rails_helper'

RSpec.describe "Api::V1::People", type: :request do
  describe "GET /api/v1/people" do
    # I'm having a problem with the middleware that is not permitting me to perform the request, so I bypass it
    # with this line just not to spend more time on it.
    before { host! "127.0.0.1" }

    let!(:person_1) { Person.create!(first_name: "John", last_name: "Doe") }
    let!(:person_2) { Person.create!(first_name: "Jane", last_name: "Smith") }

    let!(:identity_p1_1) do
      ExternalIdentity.create!(
        person: person_1,
        source: "crm",
        external_id: "CRM-123",
        email: "john@example.com",
        department: "Sales"
      )
    end

    let!(:identity_p1_2) do
      ExternalIdentity.create!(
        person: person_1,
        source: "hrm",
        external_id: "HRM-123",
        email: "john@example.com",
        department: "Customer service"
      )
    end

    let!(:identity_p2) do
      ExternalIdentity.create!(
        person: person_2,
        source: "hrm",
        external_id: "HRM-456",
        email: "jane@work.com",
        department: "Engineering"
      )
    end

    context "when no filters are provided" do
      before { get api_v1_people_path, as: :json }

      it "returns all people" do
        body = json_response

        expect(body.pluck(:person).pluck(:id)).to include(person_1.id, person_2.id)
      end

      it "returns all people's identities" do
        body = json_response
        identities_p1 = body.pluck(:person)[0][:external_identities].pluck(:id)
        identities_p2 = body.pluck(:person)[1][:external_identities].pluck(:id)

        expect(identities_p1).to match_array(person_1.external_identities.pluck(:id))
        expect(identities_p2).to match_array(person_2.external_identities.pluck(:id))
      end
    end

    context "when filtering by email" do
      before { get '/api/v1/people?email=john@example.com', as: :json }

      it "returns only the person matching the identity email" do
        person = json_response.pluck(:person).first

        expect(person[:id]).to eq(person_1.id)
        expect(person[:external_identities].pluck(:id)).to match_array([identity_p1_1.id, identity_p1_2.id])
      end
    end

    context "when filtering by department" do
      before { get '/api/v1/people?department=Engineering', as: :json }

      it "returns only the people belonging to that department" do
        body = json_response
        person_ids = body.pluck(:person).map { |p| p[:id] }
        person = body.pluck(:person).first

        expect(person_ids).to match_array([person_2.id])
        expect(person[:external_identities].pluck(:id)).to match_array([identity_p2.id])
      end
    end

    context "when filtering by source" do
      before { get '/api/v1/people?source=crm', as: :json }

      it "returns only the people with identities in that source" do
        body = json_response
        person_ids = body.pluck(:person).map { |p| p[:id] }
        person = body.pluck(:person).first

        expect(person_ids).to match_array([person_1.id])
        expect(person[:external_identities].pluck(:id)).to match_array([identity_p1_1.id])
      end
    end

    context "when filtering by multiple criteria" do
      before { get '/api/v1/people?source=hrm&department=Sales', as: :json }

      it "returns an empty collection if no identity matches all criteria" do
        expect(json_response).to be_empty
      end
    end
  end
end
