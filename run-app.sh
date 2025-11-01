#!/bin/sh

echo "starting daemons..."
ruby bom-reminderd &
ruby bom-scheduled &
ruby bom-maild &
ruby bom-smsd &

echo "starting bof-o-matic"
exec bundle exec ruby bof-o-matic -o 0.0.0.0 -p 4590