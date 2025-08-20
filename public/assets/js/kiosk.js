var kioskTimer;
var kioskTimeout;
var kioskInterval;
var kioskIntervalStarted;

function kioskTimerInit(timeout) {
  // we accept time in seconds but deal in milliseconds ourself
  kioskTimeout = timeout * 1000;
}

function kioskTimerStart() {
  // timer to do the actual timeout and redirect back
  kioskTimer = setTimeout(function() {
    window.location.href =("/kiosk_timeout");
  }, kioskTimeout);
  
  // interval to update the on-screen timer once a second
  kioskIntervalStarted = Date.now();
  kioskUpdateTimerDisplay();
  kioskInterval = setInterval(function() {
    kioskUpdateTimerDisplay();
  }, 1000);
}

function kioskUpdateTimerDisplay() {
  let secsPassed = (Date.now() - kioskIntervalStarted) / 1000;
  var totalSecsLeft = Math.floor(kioskTimeout/1000 - secsPassed);
  if(totalSecsLeft < 0) {
    totalSecsLeft = 0;
  }
  var minsLeft = Math.floor(totalSecsLeft / 60);
  var secsLeft = totalSecsLeft % 60;

  var msg = "Timeout: " + minsLeft + ":" + secsLeft.toString().padStart(2, "0");
  if(totalSecsLeft < 15) {
    msg = "<div class='bg-danger text-white'>" + msg + "</span>"
  } else if(totalSecsLeft < 60) {
    msg = "<span class='text-danger'>" + msg + "</span>"
  }

  document.getElementById("timer").innerHTML = msg;
}

function kioskTimerReset() {
  if(kioskTimer !== undefined) {
    clearTimeout(kioskTimer);
  }
  kioskTimerStart();
}

