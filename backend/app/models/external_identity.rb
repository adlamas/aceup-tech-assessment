class ExternalIdentity < ApplicationRecord
  belongs_to :person

  SOURCES = %w[crm hrm].freeze

  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :external_id, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :email, uniqueness: { scope: :source, message: 'it already exists for this data source.' }
  
  validates :external_id, uniqueness: { scope: :source, message: 'this ID has already been registered for this provider' }

  scope :by_source, ->(source) { where(source: source) if source.present? }
  scope :by_email, ->(email) { where(email: email) if email.present? }
  scope :by_department, ->(dept) { where(department: dept) if dept.present? }
end
