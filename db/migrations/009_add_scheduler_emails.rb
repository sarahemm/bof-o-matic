Sequel.migration do
  up do
    alter_table :schedulers do
      add_column :email, String
    end
  end

  down do
    alter_table :schedulers do
      drop_column :email
    end
  end
end
