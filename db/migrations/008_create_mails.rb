Sequel.migration do
  up do
    create_table :mails do
      primary_key :id
      String :to_address, null: false
      String :subject, null: false
      String :body, null: false
      String :status, size: 5, null: false, default: "READY" # READY, RETRY, ERROR, SENT
      DateTime :queued_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :mails
  end
end
