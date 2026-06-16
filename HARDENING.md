<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **taiki-e--create-gh-release-action/v1.9.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In main.sh, the variables `computed_prefix` and `version` are derived from `INPUT_REF` / `GITHUB_REF` (both workflow-controlled, untrusted inputs) and written to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). The writes are:

```bash
printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"
printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"
```

Although a semver regex validation earlier in the script provides some mitigation (bailing if the tag doesn't match), the prescribed sanitization (`tr -d '\n\r'` applied to the value immediately before the write) is absent. Per the check rules, sanitization is required for every write to a special environment file when the source is untrusted input. A calling workflow that sets `inputs.ref` to a crafted value containing a newline could — if the regex check were ever bypassed or relaxed — inject additional key=value pairs into `$GITHUB_OUTPUT`.

Locations:

- `main.sh:155`
- `main.sh:156`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in main.sh by sanitizing `computed_prefix` and `version` before writing to $GITHUB_OUTPUT. Added `safe_computed_prefix=$(printf '%s' "${computed_prefix}" | tr -d '\n\r')` and `safe_version=$(printf '%s' "${version}" | tr -d '\n\r')` intermediate variables, then used those sanitized values in the printf writes to $GITHUB_OUTPUT. This prevents newline injection from untrusted INPUT_REF/GITHUB_REF-derived values.

