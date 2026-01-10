class CreateUnifiedPeopleSchema < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.timestamps
    end

    create_table :external_identities do |t|
      t.references :person,   null: false, foreign_key: true
      t.string :source,       null: false
      t.string :external_id,  null: false
      t.string :email,        null: false

      t.string :department
      
      t.jsonb :metadata, default: {} 
      
      t.datetime :external_updated_at
      t.timestamps
    end

    add_index :external_identities, [:email, :source], unique: true
    add_index :external_identities, [:source, :external_id], unique: true

    add_index :external_identities, :email
    add_index :external_identities, :department
    add_index :external_identities, :source
  end
end
