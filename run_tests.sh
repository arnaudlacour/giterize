#!/usr/bin/env sh
set -x

# verify that the template file was expanded
test -f /server.conf || exit 1

# verify that the static file was copied correctly
test -f /README.md || exit 2

# verify the variable expansion has worked
grep expands /server.conf | grep ${VERBOSE} || exit 3

# verify the run-time variable is safe
grep run-time /server.conf | grep '${VERBOSE}' || exit 4