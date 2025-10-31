# bof-o-matic
Management system for Birds of a Feather/BoF sessions at a conference

To get up and running:
1. Do any required config in bof-o-matic.yaml
1. Make sure you have dependencies installed: Sinatra, Sequel, sqlite3, haml (v5), bcrypt, add\_to\_calendar, Prawn (if you want to generate PDFs), and RMagick (if you want to generate PNG labels)
1. Set up the DB schema: rake db:migrate
1. Download a current copy of Bootstrap into public/assets/css/bootstrap.bundle.min.css and public/assets/js/bootstrap.js.
1. Download a current copy of jQuery into public/assets/js/jquery.min.js
1. Create the initial scheduler user: rake db:add\_sysop\_user
1. Run the app! The initial login is username 'sysop' and password 'correct horse bof changeme'.
1. You'll probably want to run the following as well, which are daemons by default but can be run with -f to foreground them:
   * bom-reminderd: Send reminders X minutes before the session starts.
   * bom-scheduled: Send "ready for scheduling" notices to admins if sessions aren't self-scheduled in time.
   * bom-maild: Send queued emails via SMTP.
   * bom-smsd: Send queued text messages via Twilio.
