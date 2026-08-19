#!/bin/sh
# Fake gh CLI for testing create-gh-release-action
# Simulates: gh release view (returns 1 = no existing release)
#            gh release create (returns 0 = success)
# All other gh commands are passed through to the real gh if available.

case "$*" in
  *"release view"*)
    # Simulate no existing release (exit 1 means not found)
    exit 1
    ;;
  *"release create"*)
    # Simulate successful release creation
    echo "https://github.com/test-owner/test-repo/releases/tag/test"
    exit 0
    ;;
  *"release delete"*)
    # Simulate successful release deletion
    exit 0
    ;;
esac

# Fall through to real gh if available
if command -v /usr/bin/gh >/dev/null 2>&1; then
  exec /usr/bin/gh "$@"
fi
# If no real gh, just exit 0 for unknown commands
exit 0
