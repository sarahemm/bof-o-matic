function validateInterest() {
  // We check things from bottom to top, so that the topmost problem ends up
  // with focus
  
  rv = true;

  // Make sure the email looks at least vaguely email-ey, if entered
  email = document.querySelector('#email.form-control');
  phone = document.querySelector('#phone.form-control');
  alertbox = document.getElementById('email-alert');
  phone_alertbox = document.getElementById('phone-alert');
  if(email.value.length > 0 && (email.value.indexOf('@') < 0 || email.value.indexOf(' ') >= 0)) {
    alertbox.innerHTML = "<div class='alert alert-danger'>Your email address must contain an @ symbol and must not contain any spaces.</div>";
    alertbox.focus();
    rv = false;
  } else if(phone.value.length > 0 && phone.value.length < 8) {
    phone_alertbox.innerHTML = "<div class='alert alert-danger'>Phone numbers must be at least 8 digits long.</div>";
    alertbox.focus();
    rv = false;
  } else {
    alertbox.innerHTML = "";
  }
  
  // Make sure they entered a name
  namefield = document.querySelector('#name.form-control');
  alertbox = document.getElementById('name-alert');
  if(namefield.value.length == 0) {
    alertbox.innerHTML = "<div class='alert alert-danger'>You must enter a name.</div>";
    alertbox.focus();
    rv = false;
  } else {
    alertbox.innerHTML = "";
  }

  return rv;
}

function validateProposal() {
  rv = true;

  // Make sure the email looks at least vaguely email-ey
  email = document.querySelector('#email.form-control');
  phone = document.querySelector('#phone.form-control');
  alertbox = document.getElementById('email-alert');
  phone_alertbox = document.getElementById('phone-alert');
  if(email.value == "" && phone.value == "") {
    alertbox.innerHTML = "<div class='alert alert-danger'>You must provide either an email address or a phone number.</div>";
    rv = false
  } else if(phone.value != "" && phone.value.length < 8) {
    phone_alertbox.innerHTML = "<div class='alert alert-danger'>Phone numbers must be at least 8 digits long.</div>";
    rv = false
  } else if(email.value != "" && email.value.indexOf('@') < 0 || email.value.indexOf(' ') >= 0) {
    alertbox.innerHTML = "<div class='alert alert-danger'>Your email address must contain an @ symbol and must not contain any spaces.</div>";
    alertbox.focus();
    rv = false;
  } else {
    alertbox.innerHTML = "";
  }
  
  // Make sure they entered a name
  namefield = document.querySelector('#name.form-control');
  alertbox = document.getElementById('name-alert');
  if(namefield.value.length == 0) {
    alertbox.innerHTML = "<div class='alert alert-danger'>You must enter a name.</div>";
    alertbox.focus();
    rv = false;
  } else {
    alertbox.innerHTML = "";
  }
  
  // Make sure they entered a title
  titlefield = document.querySelector('#title.form-control');
  alertbox = document.getElementById('title-alert');
  if(titlefield.value.length == 0) {
    alertbox.innerHTML = "<div class='alert alert-danger'>You must enter a session title.</div>";
    alertbox.focus();
    rv = false;
  } else {
    alertbox.innerHTML = "";
  }

  // Make sure they entered a description
  descfield = document.querySelector('#description.form-control');
  alertbox = document.getElementById('description-alert');
  if(descfield.value.length == 0) {
    alertbox.innerHTML = "<div class='alert alert-danger'>You must enter a session description.</div>";
    alertbox.focus();
    rv = false;
  } else {
    alertbox.innerHTML = "";
  }

  return rv;
}
