# bof-o-matic
Management system for Birds of a Feather/BoF sessions at a conference

To get up and running:
1. Do any required config in bof-o-matic.yaml
1. Make sure you have dependencies installed: Sinatra, Sequel, sqlite3, haml (v5), bcrypt, add\_to\_calendar, and Prawn (if you want to generate PDFs)
1. Set up the DB schema: rake db:migrate
1. Download a current copy of Bootstrap into public/assets/css/bootstrap.bundle.min.css and public/assets/js/bootstrap.js.
1. Download a current copy of jQuery into public/assets/js/jquery.min.js
1. Insert at least one user into the 'schedulers' table
1. Run the app!
