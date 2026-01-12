
json.array! @people do |person|
  json.partial! "people/person", person: person
end
