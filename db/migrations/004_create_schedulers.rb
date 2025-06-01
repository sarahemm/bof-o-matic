Sequel.migration do
  up do
    create_table :schedulers do
      primary_key :id
      String :username, null: false
      String :pwhash, null: false
    end
  end

  down do
    drop_table :schedulers
  end
end
