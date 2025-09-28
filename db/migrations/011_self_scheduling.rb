Sequel.migration do
  up do
    alter_table :proposals do
      add_column :scheduling_token, String
      add_column :sent_to_schedulers, TrueClass, default: false
    end
  end

  down do
    alter_table :proposals do
      drop_column :scheduling_token
      drop_column :sent_to_schedulers
    end
  end
end
