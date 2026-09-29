Sequel.migration do
  up do
    create_table :blocked_times do
      primary_key :id
      DateTime :start_time, null: false
      Integer :duration, null: false
      String :description, null: false
      String :created_by, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :blocked_times
  end
end
