
json.status @errors.any? ? 'partial_success' : 'success'

json.people @people do |person|
  json.partial! "ingest/crm/people/person", person: person[:person]
end

json.errors @errors do |error|
  json.external_id error[:external_id]
  json.message error[:message]
end
