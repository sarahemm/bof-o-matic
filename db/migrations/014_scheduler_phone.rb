Sequel.migration do
  up do
    alter_table :schedulers do
      add_column :phone, String
    end
  end

  down do
    alter_table :schedulers do
      drop_column :phone
    end
  end
end
