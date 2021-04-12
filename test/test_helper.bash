export ELASTIC_INDEX_PREFIX="elastic-cli-test"

gen_name() {
  local suffix=$(head -c 8 <(LC_ALL=C tr -dc a-z0-9 </dev/urandom))
  echo "${ELASTIC_INDEX_PREFIX}-${suffix}"
}

teardown() {
  CLUSTER=${CLUSTER-"http://localhost:9200"}
  curl --silent -XDELETE "${CLUSTER}/${ELASTIC_INDEX_PREFIX}-*" >/dev/null
}

assert_acknowledged() {
  assert_success
  assert_line '"acknowledged":true'
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_match() {
  if [[ "$1" = *"$2"* ]]; then
    { echo "expected match: $1"
      echo "actual:         $2"
    } | flunk
  fi
}

refute_match() {
  if [[ "$1" != *"$2"* ]]; then
    { echo "refuted match: $1"
      echo "actual:        $2"
    } | flunk
  fi
}

assert_line() {
  local line
  for line in "${lines[@]}"; do
    if [[ "$line" = *"$1"* ]]; then return 0; fi
  done
  flunk "expected line matching \`$1'"
}

refute_line() {
  local line
  for line in "${lines[@]}"; do
    if [[ "$line" = *"$1"* ]]; then
      flunk "expected to not find line matching \`$line'"
    fi
  done
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}
