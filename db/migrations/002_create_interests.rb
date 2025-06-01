Sequel.migration do
  up do
    create_table :interests do
      primary_key :id
      Integer :proposal_id, null: false
      String :name, null: false
      String :email
      DateTime :submitted_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :interests
  end
end
