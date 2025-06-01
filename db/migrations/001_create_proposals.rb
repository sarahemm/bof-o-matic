Sequel.migration do
  up do
    create_table :proposals do
      primary_key :id
      String :submitted_by, null: false
      String :submitter_email, null: false
      String :title, null: false
      String :description, null: false
      String :scheduler_notes
      DateTime :submitted_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :proposals
  end
end
