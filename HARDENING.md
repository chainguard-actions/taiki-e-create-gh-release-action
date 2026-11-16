<!-- markdownlint-disable -->

# Hardening Report: taiki-e--create-gh-release-action/v1.11.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **taiki-e--create-gh-release-action/v1.11.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. In main.sh, the variables `computed_prefix` and `version` are derived from `INPUT_REF` (which maps to the user-controlled `inputs.ref` input, or the inherited `GITHUB_REF` env var) and written to `$GITHUB_OUTPUT` without the required newline-stripping sanitization (`tr -d '\n\r'`). An attacker supplying a crafted `ref` input containing embedded newlines could inject additional key=value pairs into `$GITHUB_OUTPUT`, potentially overwriting subsequent step outputs. The offending lines are:
  `printf 'computed-prefix=%s\n' "${computed_prefix}" >> "${GITHUB_OUTPUT}"`
  `printf 'version=%s\n' "${version}" >> "${GITHUB_OUTPUT}"`
Fix: sanitize before writing, e.g.:
  `safe=$(printf '%s' "${computed_prefix}" | tr -d '\n\r')`
  `printf 'computed-prefix=%s\n' "${safe}" >> "${GITHUB_OUTPUT}"`

Locations:

- `main.sh:196`
- `main.sh:197`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index b447de7..498c910 100644
--- a/action.yml
+++ b/action.yml
@@ -1,14 +1,13 @@
 name: Create GitHub Releases based on changelog
 description: GitHub Action for creating GitHub Releases based on changelog
-
 inputs:
   changelog:
     description: Path to changelog (variables `$tag`, `$version`, `$prefix`, and any string)
     required: false
   allow-missing-changelog:
     description: >
-      Create the release even if the changelog entry corresponding to the version is missing.
-      The default value of the changelog will be an empty string.
+      Create the release even if the changelog entry corresponding to the version is missing. The default value of the changelog will be an empty string.
+
     required: false
     default: 'false'
   title:
@@ -24,55 +23,62 @@ inputs:
     required: false
   prefix:
     description: >
-      An optional pattern that matches a prefix for the release tag, before the
-      version number.
+      An optional pattern that matches a prefix for the release tag, before the version number.
+
+      If a prefix is provided, an optional '-' character is permitted (but not required) between the prefix and the version number.   For example, the tags 'my-crate-v0.1.2' and 'my-crate0.1.0' both have the prefix 'my-crate'.
 
-      If a prefix is provided, an optional '-' character is permitted (but not
-      required) between the prefix and the version number.   For example, the
-      tags 'my-crate-v0.1.2' and 'my-crate0.1.0' both have the prefix 'my-crate'.
+      This is interpreted as a bash-style regular expression, so it may be used to match multiple prefix strings. Therefore, literal characters that are part of bash's regular expression syntax, such as `$`, `^`, `[`, `]`, `{`, `}`, `(`, `)`, and `|` must be escaped if they occur in the prefix pattern.
 
-      This is interpreted as a bash-style regular expression, so it may be used
-      to match multiple prefix strings. Therefore, literal characters that
-      are part of bash's regular expression syntax, such as `$`, `^`, `[`, `]`,
-      `{`, `}`, `(`, `)`, and `|` must be escaped if they occur in the prefix
-      pattern.
+      If a prefix pattern is provided, the portion of the tag that matched the prefix can be interpolated into `title` and `changelog` via the `$prefix` variable.
 
-      If a prefix pattern is provided, the portion of the tag that matched the
-      prefix can be interpolated into `title` and `changelog` via the `$prefix`
-      variable.
     required: false
     default: ''
   token:
     description: >
       GitHub token for creating GitHub Releases.
 
-      If not set this option, the GITHUB_TOKEN environment variable will be used.
-      If not set both this option and the GITHUB_TOKEN environment variable, github.token will be used.
+      If not set this option, the GITHUB_TOKEN environment variable will be used. If not set both this option and the GITHUB_TOKEN environment variable, github.token will be used.
+
     required: false
   ref:
     description: >
       Fully-formed tag ref for this release.
 
       If not set this option, the GITHUB_REF environment variable (automatically set by GitHub Actions) will be used.
-    required: false
 
+    required: false
 outputs:
   computed-prefix:
     description: >
       The computed prefix, including '-' and 'v' if found.
+
     value: ${{ steps.main.outputs.computed-prefix }}
   version:
-    description:
-      The version number extracted from the tag. The tag name is a concatenation of computed-prefix
-      and version.
+    description: The version number extracted from the tag. The tag name is a concatenation of computed-prefix and version.
     value: ${{ steps.main.outputs.version }}
-
 # Note:
 # - inputs.* should be manually mapped to INPUT_* due to https://github.com/actions/runner/issues/665
 # - Use GITHUB_*/RUNNER_* instead of github.*/runner.* due to https://github.com/actions/runner/issues/2185
 runs:
   using: composite
   steps:
     - id: main
       run: bash --noprofile --norc "$
... (truncated)
```

Locations:

- `action.yml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed main.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/main.sh b/main.sh
index e87c1b2..100d018 100755
--- a/main.sh
+++ b/main.sh
@@ -192,8 +192,10 @@ GITHUB_TOKEN="${token}" retry gh release create "${release_options[@]}" --title
 # Set (computed) prefix and version outputs for future step use.
 computed_prefix=${tag%"${version}"}
 if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
-  printf 'computed-prefix=%s\n' "${computed_prefix}" >>"${GITHUB_OUTPUT}"
-  printf 'version=%s\n' "${version}" >>"${GITHUB_OUTPUT}"
+  safe_computed_prefix=$(printf '%s' "${computed_prefix}" | tr -d '\n\r')
+  safe_version=$(printf '%s' "${version}" | tr -d '\n\r')
+  printf 'computed-prefix=%s\n' "${safe_computed_prefix}" >>"${GITHUB_OUTPUT}"
+  printf 'version=%s\n' "${safe_version}" >>"${GITHUB_OUTPUT}"
 else
   # Self-hosted runner may not set GITHUB_OUTPUT.
   warn "GITHUB_OUTPUT is not set; skip setting 'computed-prefix' and 'version' outputs"

```

Locations:

- `main.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, prior-fix

**Notes:**

In main.sh, `computed_prefix` and `version` now have newlines (`\n`, `\r`) stripped with `tr -d '\n\r'` before they are written to `$GITHUB_OUTPUT`. This is the same change the previous harden made to main.sh. I left action.yml unchanged. The part of the previous action.yml patch I could see (the shown diff was cut off) only reflowed description text. The step already passes every input through `env:` and has no `${{ }}` expressions inside `run:`, so there was no security change to re-apply there. Nothing was run to test the change.

