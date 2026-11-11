Sequel.migration do
  up do
    alter_table :proposals do
      add_column :edit_token, String
    end
  end

  down do
    alter_table :proposals do
      drop_column :edit_token
    end
  end
end
