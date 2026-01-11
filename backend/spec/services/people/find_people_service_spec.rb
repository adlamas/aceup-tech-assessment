require 'rails_helper'

RSpec.describe People::FindPeopleService, type: :model do
  describe '#call' do
    let!(:person_1) { Person.create!(first_name: "John", last_name: "Doe") }
    let!(:person_2) { Person.create!(first_name: "Jane", last_name: "Smith") }

    let!(:identity_1) do
      ExternalIdentity.create!(
        person: person_1,
        source: "crm",
        email: "john@example.com",
        department: "Sales",
        external_id: "CRM-1"
      )
    end

    let!(:identity_2) do
      ExternalIdentity.create!(
        person: person_2,
        source: "hrm",
        email: "jane@work.com",
        department: "Engineering",
        external_id: "HRM-2"
      )
    end

    subject(:service_call) { described_class.new(params).call }

    context "when no params are provided" do
      let(:params) { {} }

      it "returns all people" do
        expect(service_call).to include(person_1, person_2)
        expect(service_call.count).to eq(2)
      end
    end

    context "when filtering by email" do
      let(:params) { { email: "john@example.com" } }

      it "returns only people matching that email identity" do
        expect(service_call).to contain_exactly(person_1)
      end
    end

    context "when filtering by source" do
      let(:params) { { source: "hrm" } }

      it "returns only people with identities from that source" do
        expect(service_call).to contain_exactly(person_2)
      end
    end

    context "when filtering by department" do
      let(:params) { { department: "Sales" } }

      it "returns only people in that department" do
        expect(service_call).to contain_exactly(person_1)
      end
    end

    context "when filtering by multiple criteria" do
      context "and a match exists" do
        let(:params) { { source: "crm", department: "Sales" } }

        it "returns the matching person" do
          expect(service_call).to contain_exactly(person_1)
        end
      end

      context "and no match exists for the combination" do
        let(:params) { { source: "hrm", department: "Sales" } }

        it "returns an empty collection" do
          expect(service_call).to be_empty
        end
      end
    end
  end
end
