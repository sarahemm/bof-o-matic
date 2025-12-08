Sequel.migration do
  up do
    create_table :api_keys do
      primary_key :id
      String :key, null: false
      Integer :access_level, null: false
      String :description, null: false
      String :issued_by, null: false
      DateTime :issued_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :api_keys
  end
end
