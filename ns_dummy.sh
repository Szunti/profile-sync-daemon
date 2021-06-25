#!/usr/bin/bash

# This spawns an idle process to keep namespaces alive and returns the
# pid of the spawned process on standard output

( trap 'kill $(jobs -p)' EXIT
  exec >&-
  while true; do
      sleep 1000000
  done
)&
echo $(jobs -p %%)
exec >&-
