json.person do
  json.id person.id
  json.first_name person.first_name
  json.last_name person.last_name

  json.external_identities person.external_identities do |identity|
    json.id identity.id
    json.source identity.source
    json.external_id identity.external_id
    json.email identity.email
    json.department identity.department
    json.metadata identity.metadata
  end
end
