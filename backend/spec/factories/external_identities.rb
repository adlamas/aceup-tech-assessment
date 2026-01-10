
FactoryBot.define do
  factory :external_identity do
    person
    source { ExternalIdentity::SOURCES.sample }
    
    sequence(:external_id) { |n| "ID-#{n}-#{Faker::Alphanumeric.alphanumeric(number: 5)}" }
    sequence(:email) { |n| "user#{n}_#{Faker::Internet.unique.email}" }
    
    department { Faker::Job.field }
    external_updated_at { Faker::Time.backward(days: 14) }
    
    metadata do
      {
        last_login_ip: Faker::Internet.ip_v4_address,
        user_agent: Faker::Internet.user_agent
      }
    end

    trait :crm do
      source { 'crm' }
    end

    trait :hrm do
      source { 'hrm' }
      department { 'Engineering' }
    end
  end
end
