<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.11.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **taiki-e--create-gh-release-action/v1.11.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In main.sh, the values `computed_prefix` and `version` — both derived from user-controlled inputs (`INPUT_REF` / `inputs.ref` and `INPUT_PREFIX` / `inputs.prefix`) — are written to `$GITHUB_OUTPUT` without the required `tr -d '\n\r'` sanitization step. The writes use `printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"` and `printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"`. While a semver regex validation earlier in the script would reject newlines in practice, the check requires the explicit sanitization pipeline (`printf '%s' "$VAR" | tr -d '\n\r'`) immediately before every write to a special environment file when the source is untrusted input. The sanitization step is absent, making this a FAIL under the github-env-injection rule.

Locations:

- `main.sh:196`
- `main.sh:197`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed main.sh lines 196-197: added `tr -d '\n\r'` sanitization for both `computed_prefix` and `version` before writing them to `$GITHUB_OUTPUT`. Introduced `safe_computed_prefix` and `safe_version` intermediate variables using `printf '%s' "${VAR}" | tr -d '\n\r'`, then used those sanitized values in the `printf` writes to `$GITHUB_OUTPUT`. The unsanitized variables are still used in the fallback (non-GITHUB_OUTPUT) path for display purposes only, which is safe.

