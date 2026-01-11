
json.array! @people do |person|
  json.partial! "api/v1/people/identity", person: person
end
