#!/bin/sh

echo "starting daemons..."
echo "- bom-reminderd"
ruby bom-reminderd
echo "- bom-scheduled"
ruby bom-scheduled
echo "- bom-maild"
ruby bom-maild
echo "- bom-smsd"
ruby bom-smsd
echo "- bom-labeld"
ruby bom-labeld -f &

echo "starting bof-o-matic"
exec bundle exec ruby bof-o-matic -o 0.0.0.0 -p 4590
