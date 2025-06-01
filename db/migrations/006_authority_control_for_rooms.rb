Sequel.migration do
  up do
    alter_table :schedules do
      add_column :room_id, Integer
    end

    # create room entries for any schedule entries that already exist
    from(:rooms).insert([:room_name], from(:schedules).select(:room).distinct)

    # add the room IDs to the schedule entries
    from(:schedules).update(room_id: from(:rooms).select(:id).where(room_name: :room))
  end

  down do
    raise Sequel::Error.new "Rolling back from room authority control is not supported."
  end
end
