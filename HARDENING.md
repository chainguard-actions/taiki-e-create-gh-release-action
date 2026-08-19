<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **taiki-e--create-gh-release-action/v1.9.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references are pinned to mutable branch or tag refs instead of immutable 40-character commit SHAs, making the workflows vulnerable to supply-chain attacks if those refs are moved:
- `.github/workflows/ci.yml`: `uses: taiki-e/github-actions/.github/workflows/tidy.yml@main` (branch ref)
- `.github/workflows/release.yml`: `uses: taiki-e/checkout-action@v1` (tag ref)
- `.github/workflows/release.yml`: `uses: taiki-e/create-gh-release-action@v1` (tag ref)

Locations:

- `.github/workflows/ci.yml:22`
- `.github/workflows/release.yml:20`
- `.github/workflows/release.yml:21`

### github-env-injection (severity: high)

In `main.sh`, the variables `computed_prefix` and `version` are derived from the user-controlled input `INPUT_REF` (via `$ref` → `$tag`) and written to `$GITHUB_OUTPUT` without the required newline-stripping sanitization (`printf '%s' "$VAR" | tr -d '\n\r'`). A crafted tag ref containing an embedded newline character could inject additional key=value pairs into GITHUB_OUTPUT. The current code uses `printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"` and `printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"`, which does not strip newlines from the values themselves.

Locations:

- `main.sh:176`
- `main.sh:177`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all findings: (1) Pinned taiki-e/github-actions/.github/workflows/tidy.yml from mutable 'main' branch ref to SHA 3da7d39bb26122d232edd731a1813082711e3037 in ci.yml; (2) Pinned taiki-e/checkout-action from tag v1 to SHA 7d1e50e93dc4fb3bba58f85018fadf77898aee8b in release.yml; (3) Pinned taiki-e/create-gh-release-action from tag v1 to SHA eba8ea96c86cca8a37f1b56e94b4d13301fba651 in release.yml; (4) Fixed github-env-injection in main.sh by stripping newlines from computed_prefix and version using `printf '%s' "$VAR" | tr -d '\n\r'` before writing to GITHUB_OUTPUT, preventing newline injection attacks from crafted tag refs.

