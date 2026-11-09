Sequel.migration do
  up do
    # no reason to have BoFs with the same name and it causes issues, enforce uniqueness
    alter_table :proposals do
      add_unique_constraint :title
    end
  end

  down do
    alter_table :proposals do
      drop_constraint :title, type: :unique
    end
  end
end
