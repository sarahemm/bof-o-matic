Sequel.migration do
  up do
    create_table :rooms do
      primary_key :id
      String :room_name, null: false, unique: true
      TrueClass :active, null: false, default: true
    end
  end

  down do
    drop_table :rooms
  end
end
