require 'rails_helper'

RSpec.describe ExternalIdentity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:person) }
  end

  describe 'validations' do
    subject { create(:external_identity) }

    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_inclusion_of(:source).in_array(%w[crm hrm]) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:email) }

    it do
      is_expected.to validate_uniqueness_of(:email)
        .scoped_to(:source)
        .with_message('it already exists for this data source.')
    end

    it do
      is_expected.to validate_uniqueness_of(:external_id)
        .scoped_to(:source)
        .with_message('this ID has already been registered for this provider')
    end

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid_email').for(:email) }
  end

  describe 'scopes' do
    let!(:crm_identity) { create(:external_identity, source: 'crm', department: 'Sales', email: 'crm@test.com') }
    let!(:hrm_identity) { create(:external_identity, source: 'hrm', department: 'Eng', email: 'hrm@test.com') }

    it 'filters by source' do
      expect(ExternalIdentity.by_source('crm')).to include(crm_identity)
      expect(ExternalIdentity.by_source('crm')).not_to include(hrm_identity)
    end

    it 'filters by email' do
      expect(ExternalIdentity.by_email('crm@test.com')).to include(crm_identity)
      expect(ExternalIdentity.by_email('crm@test.com')).not_to include(hrm_identity)
    end

    it 'filters by department' do
      expect(ExternalIdentity.by_department('Eng')).to include(hrm_identity)
      expect(ExternalIdentity.by_department('Eng')).not_to include(crm_identity)
    end
  end
end
