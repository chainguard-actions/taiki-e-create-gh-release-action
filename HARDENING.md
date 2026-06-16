<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **taiki-e--create-gh-release-action/v1.10.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In main.sh, the values `computed_prefix` and `version` — both derived from `INPUT_REF` (the `ref` input, which is user-controlled) — are written to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). The writes use `printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"` and `printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"`. Although the tag value is validated against a semver regex (which would reject most newline-based attacks), the sanitization step is not applied immediately before the write as required by the check. An attacker who can control the `ref` input (or the `GITHUB_REF` environment variable in a calling workflow) could potentially inject additional key=value pairs into `$GITHUB_OUTPUT` if the regex validation is bypassed.

Locations:

- `main.sh:161`
- `main.sh:162`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in main.sh at lines 161-162. Added sanitization step before writing computed_prefix and version to $GITHUB_OUTPUT. Both values are now passed through `printf '%s' "$VAR" | tr -d '\n\r'` to strip newline characters before being written to $GITHUB_OUTPUT, preventing potential injection of additional key=value pairs. The sanitized values are stored in safe_computed_prefix and safe_version variables respectively.

