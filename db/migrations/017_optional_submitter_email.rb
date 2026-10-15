Sequel.migration do
  up do
    # proposers may give a phone number instead of an email
    alter_table :proposals do
      set_column_allow_null :submitter_email
    end
  end

  down do
    alter_table :proposals do
      set_column_not_null :submitter_email
    end
  end
end
