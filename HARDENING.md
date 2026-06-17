<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.9.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **taiki-e--create-gh-release-action/v1.9.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In main.sh, the values `computed_prefix` and `version` are derived from `INPUT_REF` (the untrusted `inputs.ref` composite-action input, set via the env: block in action.yml) and written directly to $GITHUB_OUTPUT using `printf` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Although the script validates that the tag matches a semver regex, bash's `=~` operator treats `$` as matching before an embedded newline, so a crafted ref value such as `refs/tags/v1.0.0\nfoo=injected` can pass validation and inject additional key-value pairs into $GITHUB_OUTPUT. The offending writes are:
  `printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"`
  `printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"`

Locations:

- `main.sh:193`
- `main.sh:194`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed main.sh lines 193-194: Added sanitization of `computed_prefix` and `version` values before writing to $GITHUB_OUTPUT. Both values are now piped through `printf '%s' ... | tr -d '\n\r'` to strip embedded newlines/carriage returns, preventing injection of additional key-value pairs into $GITHUB_OUTPUT via crafted ref values that embed newlines.

