Sequel.migration do
  up do
    alter_table :proposals do
      add_column :submitter_phone, String
    end
    alter_table :interests do
      add_column :phone, String
    end
  end

  down do
    alter_table :proposals do
      drop_column :submitter_phone
    end
    alter_table :interests do
      drop_column :phone
    end
  end
end
