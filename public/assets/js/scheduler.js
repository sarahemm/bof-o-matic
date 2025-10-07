function enableAllSchedulerRooms() {
  // enable all the scheduler dialog's rooms
  $('#rooms').children('option').each(function(){
    $(this).removeAttr('disabled');
  });
}

function markConflictingSchedulerRooms(cellId) {
  // mark which <options> are associated with rooms that already have a booking
  // at this time, we use this to later disable these
  conflictsFound = 0;
  $('#' + cellId).children('.btn').each(function() {
    control = $('#room-' + $(this).attr('data-location'))
    control.attr('data-conflict', 'true');
    // also mark them visually so they stand out better
    control.addClass('text-danger');
    control.html(control.html() + ' (room conflict)');
    conflictsFound++;
  });

  return conflictsFound;
}

function disableConflictingSchedulerRooms() {
  // disable conflicting rooms that were marked by
  // markConflictingSchedulerRooms
  $('option[data-conflict]').each(function() {
    $(this).attr('disabled', 'true');
  });
}

function gridSchedulePopup(timeslot, cellId, modalTitle) {
  // set up the modal with the time they clicked on
  $('#scheduleTitle').html("Schedule Session for " + modalTitle);
  $('#timeslot').attr('value', timeslot);
  $('#conflictOverride').prop('checked', false);
  
  // remove any previous conflict marks from past calls
  $('#rooms').children('option').each(function(){
    $(this).removeAttr('data-conflict');
    $(this).html($(this).html().replace(' (room conflict)', ''));
    $(this).removeClass('text-danger');
  });
  
  // start with all rooms enabled
  enableAllSchedulerRooms();
  // check what rooms are already booked and mark them as such with
  // a data-conflict attribute
  if(markConflictingSchedulerRooms(cellId) > 0) {
    // at least one room is already booked during this time, so disallow
    // them being selected and show the override control
    disableConflictingSchedulerRooms();
    $('#conflictOverride').show();
    $('#conflictOverrideLabel').show();
  } else {
    // no rooms are booked, so hide the 'override conflicts' button to avoid
    // the extra clutter
    $('#conflictOverride').hide();
    $('#conflictOverrideLabel').hide();
  }
  
  scheduleModal = new bootstrap.Modal('#scheduleModal');
  scheduleModal.show();
}

function conflictOverrideToggle() {
  if($('#conflictOverride').is(':checked')) {
    enableAllSchedulerRooms();
  } else {
    disableConflictingSchedulerRooms();
  }
}

function readyRenameRoom(name, id) {
  document.getElementById('renameTitle').innerText = "Rename " + name;
  document.getElementById('newName').value = name;
  document.getElementById('roomId').value = id;
}

function readyDeleteScheduler(username, id) {
  document.getElementById('deleteTitle').innerText = "Delete Scheduler '" + username + "'";
  document.getElementById('schedulerId').value = id;
}

function displaySchedulerNotes() {
  var notes = $('option:selected', '#unscheduledproposals').attr('data-notes');
  if(notes === undefined || notes == '') {
    $('#schedulernotes').text('');
    return;
  }
  $('#schedulernotes').text('Notes from proposer: ' + notes);
}
