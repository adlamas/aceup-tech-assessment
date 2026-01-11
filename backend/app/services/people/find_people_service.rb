
module People
  class FindPeopleService
    def initialize(params)
      @params = params
    end

    def call
      scope = Person.includes(:external_identities).references(:external_identities)
      scope = filter_by_identity_fields(scope)

      scope.distinct
    end

    private

    attr_reader :params

    def filter_by_identity_fields(scope)
      identity_filters = params.slice(:email, :source, :department).to_h.compact

      return scope if identity_filters.empty?

      scope.where(external_identities: identity_filters)
    end
  end
end
