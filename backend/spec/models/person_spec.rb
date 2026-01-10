require 'rails_helper'

RSpec.describe Person, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:external_identities) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe '#emails' do
    let(:person) { create(:person) }

    it 'returns unique emails from all its identities' do
      create(:external_identity, person: person, email: 'test@me.com', source: 'crm')
      create(:external_identity, person: person, email: 'test@me.com', source: 'hrm')
      create(:external_identity, person: person, email: 'other@me.com', source: 'crm', external_id: 'alt')

      expect(person.emails).to contain_exactly('test@me.com', 'other@me.com')
      expect(person.emails.size).to eq(2)
    end
  end
end
