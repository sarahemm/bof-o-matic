Sequel.migration do
  up do
    create_table :schedules do
      primary_key :id
      Integer :proposal_id, null: false
      String :room, null: false
      DateTime :start_time, null: false
      DateTime :scheduled_at, default: Sequel::CURRENT_TIMESTAMP
      String :scheduled_by
    end
  end

  down do
    drop_table :schedules
  end
end
