#!/usr/bin/env sh
# this script should be executed immediately before the source image original entrypoint is called
echo "Hello from the $0 hook"

echo "calling some other scripts"
sh ${VERBOSE:+-x} $(dirname $0)/03-called-from-01.sh

sh ${VERBOSE:+-x} $(dirname $0)/04-not-a-shell-extension.hook
