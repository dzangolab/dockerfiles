#!/bin/sh
set -u

failures=0

assert_eq() {
  desc=$1 expected=$2 actual=$3
  if [ "$expected" = "$actual" ]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc (expected '$expected', got '$actual')"
    failures=$((failures + 1))
  fi
}

assert_unset() {
  desc=$1 var=$2
  eval "current=\${$var:-}"
  if [ -z "$current" ]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc ($var is set to '$current')"
    failures=$((failures + 1))
  fi
}

assert_contains() {
  desc=$1 haystack=$2 needle=$3
  case "$haystack" in
    *"$needle"*)
      echo "PASS: $desc"
      ;;
    *)
      echo "FAIL: $desc ('$needle' not found in: $haystack)"
      failures=$((failures + 1))
      ;;
  esac
}

assert_not_contains() {
  desc=$1 haystack=$2 needle=$3
  case "$haystack" in
    *"$needle"*)
      echo "FAIL: $desc (found '$needle' in: $haystack)"
      failures=$((failures + 1))
      ;;
    *)
      echo "PASS: $desc"
      ;;
  esac
}

mkdir -p /run/secrets
printf 'super-secret-password' > /run/secrets/db_password
printf 'other-secret' > /run/secrets/other

. /expand_secrets.sh

# Case 1: happy path - secret under /run/secrets is expanded and _FILE var is unset
DATABASE_PASSWORD_FILE=/run/secrets/db_password
export DATABASE_PASSWORD_FILE
expand_secrets
assert_eq "expands secret value" "super-secret-password" "${DATABASE_PASSWORD:-}"
assert_unset "unsets the _FILE var after expansion" DATABASE_PASSWORD_FILE

# Case 2: path not under /run/secrets is skipped
unset DATABASE_PASSWORD
OTHER_VAR_FILE=/etc/passwd
export OTHER_VAR_FILE
expand_secrets
assert_unset "does not expand a path outside /run/secrets" OTHER_VAR
assert_eq "leaves the _FILE var untouched when skipped" "/etc/passwd" "${OTHER_VAR_FILE:-}"
unset OTHER_VAR_FILE

# Case 3: target var already set - _FILE var should be ignored, not overwritten
unset DATABASE_PASSWORD
DATABASE_PASSWORD="already-set"
export DATABASE_PASSWORD
DATABASE_PASSWORD_FILE=/run/secrets/db_password
export DATABASE_PASSWORD_FILE
err_output=$(expand_secrets 2>&1 >/dev/null)
assert_eq "keeps pre-existing value when target var already set" "already-set" "${DATABASE_PASSWORD:-}"
assert_contains "warns about already-set var" "$err_output" "is already set"
unset DATABASE_PASSWORD DATABASE_PASSWORD_FILE

# Case 4: missing secret file - var stays unset, no crash under `set -eu`
MISSING_FILE=/run/secrets/does-not-exist
export MISSING_FILE
expand_secrets
assert_unset "does not expand a non-existent secret file" MISSING
unset MISSING_FILE

# Case 5: debug output does not contain the literal word "echo"
unset OTHER
OTHER_FILE=/run/secrets/other
export OTHER_FILE
DZANGOLAB_DOCKER_SECRETS_DEBUG=1 expand_secrets > /tmp/debug.out 2>&1
debug_output=$(cat /tmp/debug.out)
assert_not_contains "debug output has no leftover literal 'echo'" "$debug_output" "echo Expanded"
assert_eq "debug run still expands the secret" "other-secret" "${OTHER:-}"
assert_not_contains "debug output does not leak the secret value" "$debug_output" "other-secret"
unset OTHER

# Case 6: trailing newlines (eg. from `echo secret > file`) are stripped
printf 'with-newline\n\n' > /run/secrets/trailing_newline
TRAILING_FILE=/run/secrets/trailing_newline
export TRAILING_FILE
expand_secrets
assert_eq "strips trailing newlines" "with-newline" "${TRAILING:-}"
unset TRAILING

# Case 7: special characters are kept verbatim, not evaluated by the shell
special='p@ss/w:rd#?+% $HOME `id` $(id) "dq" '"'sq'"' \ & ; | * [x]'
printf '%s' "$special" > /run/secrets/special
SPECIAL_FILE=/run/secrets/special
export SPECIAL_FILE
expand_secrets
assert_eq "keeps special characters verbatim" "$special" "${SPECIAL:-}"
unset SPECIAL

# Case 8: embedded newlines are preserved
printf 'line1\nline2' > /run/secrets/multiline
MULTILINE_FILE=/run/secrets/multiline
export MULTILINE_FILE
expand_secrets
assert_eq "preserves embedded newlines" "line1
line2" "${MULTILINE:-}"
unset MULTILINE

# Case 9: a multi-line value that looks like a _FILE var is not mistaken for one
SOME_VAR="first line
INJECTED_FILE=/run/secrets/other"
export SOME_VAR
expand_secrets
assert_unset "ignores _FILE assignments inside another var's value" INJECTED
unset SOME_VAR

echo
if [ "$failures" -eq 0 ]; then
  echo "All tests passed"
  exit 0
else
  echo "$failures test(s) failed"
  exit 1
fi
