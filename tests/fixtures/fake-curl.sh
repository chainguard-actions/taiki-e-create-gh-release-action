#!/bin/sh
# Fake curl: intercepts parse-changelog downloads, passes others to real curl.
# Supports both "curl URL | sh" (stdout) and "curl -o FILE URL" (file output).
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *parse-changelog*)
    if [ -n "$out" ]; then
      cat /tmp/fake-parse-changelog.tar.gz > "$out"
    else
      cat /tmp/fake-parse-changelog.tar.gz
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
