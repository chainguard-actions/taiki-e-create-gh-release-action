<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.11.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **taiki-e--create-gh-release-action/v1.11.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In main.sh, the variables `computed_prefix` and `version` are derived from `INPUT_REF` (which maps to the user-controlled `inputs.ref` input, or the inherited `GITHUB_REF` env var) and written to `$GITHUB_OUTPUT` without the required newline-stripping sanitization (`tr -d '\n\r'`). An attacker supplying a crafted `ref` input containing embedded newlines could inject additional key=value pairs into `$GITHUB_OUTPUT`, potentially overwriting subsequent step outputs. The offending lines are:
  `printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"`
  `printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"`
Fix: sanitize before writing, e.g.:
  `safe=$(printf '%s' "${computed_prefix}" | tr -d '\n\r')`
  `printf 'computed-prefix=%s\n' "${safe}" >> "${GITHUB_OUTPUT}"`

Locations:

- `main.sh:196`
- `main.sh:197`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in hardened/action/main.sh at lines 196-197. Both `computed_prefix` and `version` variables (derived from user-controlled INPUT_REF/GITHUB_REF) are now sanitized with `tr -d '\n\r'` before being written to $GITHUB_OUTPUT. This prevents an attacker from injecting additional key=value pairs into GITHUB_OUTPUT by supplying a crafted `ref` input containing embedded newlines.

