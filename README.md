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

## Authentication with oauth2-proxy (OIDC)

`docker-compose.yml` puts [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/)
in front of bof-o-matic, authenticating against the Drupal registration site's
OpenID Connect provider (`simple_oauth`), the same provider the wiki uses:

```
caddy-proxy (:443) -> bof-o-matic-auth:4180 -> bof-o-matic:4590
                           |
                           +-- OIDC --> registration.hackersconference.org
```

1. In Drupal, add an OAuth consumer at
   `/admin/config/services/consumer`:
   - **Label:** `BoF-o-matic`
   - **Redirect URI:** `https://bofs.hackersconference.org/oauth2/callback`
   - **Scopes:** `openid`, `email`, `profile`, `roles`
   - **Confidential:** yes — note the client ID and secret
1. Create a DNS A record for `bofs.hackersconference.org`.
1. Add the site to the Caddyfile in `hackers-infrastructure`:

   ``` caddyfile
   bofs.hackersconference.org {
     reverse_proxy bof-o-matic-auth:4180
   }
   ```

1. Copy `oauth2-proxy.env.example` to `oauth2-proxy.env` and fill in the client
   ID/secret and a cookie secret
   (`openssl rand -base64 32 | tr -- '+/' '-_'`).
1. `docker compose up -d`

Notes:

- Drupal `simple_oauth` 6.x does not serve
  `/.well-known/openid-configuration`, so oauth2-proxy runs with
  `--skip-oidc-discovery` and explicit `/oauth/authorize`, `/oauth/token`,
  `/oauth/userinfo` and `/oauth/jwks` URLs — the same arrangement as the
  wiki's `OIDC_ISSUER_DISCOVER=false`.
- `simple_oauth_companion` adds Drupal roles to the `roles` claim. Uncomment
  the `--allowed-group` arguments in `docker-compose.yml` to limit access to
  specific roles (e.g. `steering_committee_member`); without them, any
  registration account can get in.
- The authenticated user arrives in `X-Forwarded-User` / `X-Forwarded-Email`.
  bof-o-matic does not read those yet, so schedulers still log in at `/login`
  behind the SSO wall.
- Routes attendees reach without a registration account (interest sign-up,
  self-scheduling tokens, the API, static assets) are listed as
  `--skip-auth-route` arguments. Trim that list to tighten access.
- oauth2-proxy joins the external `caddy-proxy` network, which requires Caddy
  and bof-o-matic on the same Docker host. If the label printer keeps
  bof-o-matic on separate hardware, publish port 4180 instead (see the
  commented block in `docker-compose.yml`) and point Caddy at that host.
- The production stack no longer runs the `nginx` proxy container; the
  nginx-fronted stack lives on in `docker-compose.local.yml` for local use.

## Local development with Docker

`docker-compose.local.yml` is the plain stack — nginx in front of the app on
port 80, no oauth2-proxy and no OIDC:

``` bash
cp bof-o-matic.yaml.example bof-o-matic.yaml   # set base_url to http://localhost
docker compose -f docker-compose.local.yml up -d
```

To skip the `/login` prompt as well, set `BOM_DEV_USER` on the `bof-o-matic`
service:

``` yaml
    environment:
      BOM_DEV_USER: sysop
```

Every request is then authenticated as that scheduler. The variable is unset
everywhere else, so the production stack still requires both the OIDC login
and `/login`. **Never set `BOM_DEV_USER` on a host other people can reach** —
it disables authentication completely.
