# bof-o-matic
Management system for Birds of a Feather/BoF sessions at a conference

To get up and running:
#. Do any required config in bof-o-matic.yaml
#. Make sure you have dependencies installed: Sinatra, Sequel, sqlite3, haml, bcrypt
#. Set up the DB schema: rake db:migrate
#. Download a current copy of Bootstrap CSS into
public/assets/css/bootstrap.bundle.min.css.
public/assets/js/bootstrap.js.
#. Insert at least one user into the 'schedulers' table
#. Run the app!
