# bof-o-matic

Management system for Birds of a Feather/BoF sessions at a conference

## Required Dependencies

- ruby
- ruby-rake
- ruby-bundler
- sqlite3
- imagemagick
- python3 with pip
- brother_ql python library

## Local Environment (development, proof-of-concept)

To get up and running:

1. Copy `bof-o-matic.yaml.example` to `bof-o-matic.yaml` and do any required config changes.
1. Run `bundle install` to install all ruby dependencies
1. Run `pip install brother_ql_next` to install the python library for the printers
1. Download a current copy of Bootstrap into
   - `public/assets/css/bootstrap.bundle.min.css`
   - `public/assets/js/bootstrap.bunfle.min.js`
1. Download a current copy of jQuery into
   - `public/assets/js/jquery.min.js`
1. Set up the DB schema: `rake db:migrate`
1. Create the initial scheduler user: `rake db:add\_sysop\_user`

1. Run the app with `run-app.sh`! The initial login is:
   - username: `sysop`
   - password: `correct horse bof changeme`

You'll probably want to run the following as well, which are daemons by default but can be run with -f to foreground them:

- `bom-reminderd`: Send reminders X minutes before the session starts.
- `bom-scheduled`: Send "ready for scheduling" notices to admins if sessions aren't self-scheduled in time.
- `bom-maild`: Send queued emails via SMTP.
- `bom-smsd`: Send queued text messages via Twilio.

## Docker

1. On your docker host, get the product ID for your brother label printer. In the following example, the `productID` is 2043.

``` bash

> $ lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 2109:3431 VIA Labs, Inc. Hub
Bus 001 Device 006: ID 04f9:2043 Brother Industries, Ltd QL-710W Label Printer 
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub

```

1. Edit `90-brother-printer.rules` and change `changeme` to the productID for your printer.
1. Copy `90-brother-printer.rules` to `/etc/udev/rules.d`, then run `sudo udevadm control --reload-rules`. You may also need to power-cycle the printer. This guarantees that the bof-o-matic docker container will have the same device handle to connect to every time.
1. Copy `bof-o-matic.yaml.example` to `bof-o-matic.yaml` and do any required config changes.
1. Build the image: `docker build . --file=Dockerfile --tag=bof-o-matic:latest`
1. Start the containers: `docker compose up -d`

Note: This container initializes the DB directly inside itself during build; if you rebuild the container, you *will* lose your DB unless you take steps to preserve it.