#!/usr/bin/env bash
set -u

failures=0

assert_eq() {
  local desc=$1 expected=$2 actual=$3
  if [ "$expected" == "$actual" ]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc (expected '$expected', got '$actual')"
    failures=$((failures + 1))
  fi
}

assert_unset() {
  local desc=$1 var=$2
  if [ -z "${!var:-}" ]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc ($var is set to '${!var}')"
    failures=$((failures + 1))
  fi
}

assert_not_contains() {
  local desc=$1 haystack=$2 needle=$3
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc (found '$needle' in: $haystack)"
    failures=$((failures + 1))
  fi
}

assert_contains() {
  local desc=$1 haystack=$2 needle=$3
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc ('$needle' not found in: $haystack)"
    failures=$((failures + 1))
  fi
}

mkdir -p /run/secrets
printf 'super-secret-password' > /run/secrets/db_password
printf 'other-secret' > /run/secrets/other

# shellcheck source=/expand_secrets.sh
. /expand_secrets.sh

# Case 1: happy path - secret under /run/secrets is expanded and _FILE var is unset
export DATABASE_PASSWORD_FILE=/run/secrets/db_password
expand_secrets
assert_eq "expands secret value" "super-secret-password" "${DATABASE_PASSWORD:-}"
assert_unset "unsets the _FILE var after expansion" DATABASE_PASSWORD_FILE

# Case 2: path not under /run/secrets is skipped
unset DATABASE_PASSWORD
export OTHER_VAR_FILE=/etc/passwd
expand_secrets
assert_unset "does not expand a path outside /run/secrets" OTHER_VAR
assert_eq "leaves the _FILE var untouched when skipped" "/etc/passwd" "${OTHER_VAR_FILE:-}"
unset OTHER_VAR_FILE

# Case 3: target var already set - _FILE var should be ignored, not overwritten
unset DATABASE_PASSWORD
export DATABASE_PASSWORD="already-set"
export DATABASE_PASSWORD_FILE=/run/secrets/db_password
err_output=$(expand_secrets 2>&1 >/dev/null)
assert_eq "keeps pre-existing value when target var already set" "already-set" "${DATABASE_PASSWORD:-}"
assert_contains "warns about already-set var" "$err_output" "is already set"
unset DATABASE_PASSWORD DATABASE_PASSWORD_FILE

# Case 4: missing secret file - var stays unset, no crash under `set -eu`
export MISSING_FILE=/run/secrets/does-not-exist
expand_secrets
assert_unset "does not expand a non-existent secret file" MISSING
unset MISSING_FILE

# Case 5: debug output does not contain the literal word "echo"
unset OTHER
export OTHER_FILE=/run/secrets/other
DZANGOLAB_DOCKER_SECRETS_DEBUG=1 expand_secrets > /tmp/debug.out 2>&1
debug_output=$(cat /tmp/debug.out)
assert_not_contains "debug output has no leftover literal 'echo'" "$debug_output" "echo Expanded"
assert_eq "debug run still expands the secret" "other-secret" "${OTHER:-}"

echo
if [ "$failures" -eq 0 ]; then
  echo "All tests passed"
  exit 0
else
  echo "$failures test(s) failed"
  exit 1
fi
