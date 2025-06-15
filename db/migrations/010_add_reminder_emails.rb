Sequel.migration do
  up do
    alter_table :schedules do
      add_column :reminders_sent, TrueClass, default: false
    end
  end

  down do
    alter_table :schedules do
      drop_column :reminders_sent
    end
  end
end
