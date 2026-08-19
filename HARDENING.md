<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **taiki-e--create-gh-release-action/v1.9.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Workflow files reference GitHub Actions using mutable tags/branch names instead of pinned 40-character commit SHAs, making them vulnerable to supply-chain attacks if the referenced action is compromised or altered.

- `.github/workflows/ci.yml`: `uses: taiki-e/github-actions/.github/workflows/tidy.yml@main` (branch ref)
- `.github/workflows/release.yml`: `uses: taiki-e/checkout-action@v1` (tag ref)
- `.github/workflows/release.yml`: `uses: taiki-e/create-gh-release-action@v1` (tag ref)

Locations:

- `.github/workflows/ci.yml:21`
- `.github/workflows/release.yml:19`
- `.github/workflows/release.yml:20`

### github-env-injection (severity: high)

In `main.sh`, the values `computed_prefix` and `version` — both derived from `tag`, which originates from the user-controlled `INPUT_REF` / `GITHUB_REF` environment variable — are written to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). Although a strict semver regex validates the tag format earlier in the script (which would reject embedded newlines in practice), the sanitization step is technically absent before the writes, violating the check requirement that every write of a non-literal value to a special environment file must be preceded by sanitization.

Offending lines:
```
printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"
printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"
```

Locations:

- `main.sh:163`
- `main.sh:164`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed 3 unpinned action references by resolving them to full 40-character commit SHAs (with tag/branch comments for readability): taiki-e/github-actions@main→3da7d39bb26122d232edd731a1813082711e3037, taiki-e/checkout-action@v1→7d1e50e93dc4fb3bba58f85018fadf77898aee8b, taiki-e/create-gh-release-action@v1→eba8ea96c86cca8a37f1b56e94b4d13301fba651. Fixed github-env-injection in main.sh by sanitizing computed_prefix and version values with `printf '%s' "$VAR" | tr -d '\n\r'` before writing them to $GITHUB_OUTPUT.

