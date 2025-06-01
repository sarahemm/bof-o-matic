Sequel.migration do
  up do
    alter_table :schedules do
      drop_column :room
    end
  end

  down do
    raise Sequel::Error.new "Rolling back from room authority control is not supported."
  end
end
