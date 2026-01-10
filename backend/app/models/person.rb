class Person < ApplicationRecord
  has_many :external_identities, dependent: :destroy

  validates :first_name, :last_name, presence: true

  def emails
    external_identities.pluck(:email).uniq
  end
end
