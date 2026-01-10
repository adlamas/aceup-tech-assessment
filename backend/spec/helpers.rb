module Helpers
  # Helper method to parse a response
  #
  # @return [Hash]

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end
