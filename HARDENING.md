<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **taiki-e--create-gh-release-action/v1.9.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In main.sh, the values `computed_prefix` and `version` are derived from `$INPUT_REF` (mapped from `inputs.ref`, a caller-controlled untrusted input) and written directly to `$GITHUB_OUTPUT` without the required newline-stripping sanitization (`printf '%s' ... | tr -d '\n\r'`). An attacker who controls the tag ref (e.g. via a crafted `inputs.ref` value containing embedded newlines) could inject arbitrary key=value pairs into GITHUB_OUTPUT, potentially overwriting subsequent step outputs. The offending lines are:
  `printf 'computed-prefix=%s\n' "${computed_prefix}" >>"${GITHUB_OUTPUT}"`
  `printf 'version=%s\n' "${version}" >>"${GITHUB_OUTPUT}"`

Locations:

- `main.sh:157`
- `main.sh:158`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in main.sh at lines 157-158. The values `computed_prefix` and `version` (derived from caller-controlled `$INPUT_REF`) are now sanitized with `printf '%s' ... | tr -d '\n\r'` before being written to `$GITHUB_OUTPUT`. Sanitized values are stored in `safe_computed_prefix` and `safe_version` intermediate variables, preventing an attacker from injecting arbitrary key=value pairs into GITHUB_OUTPUT via embedded newlines in the tag ref input.

