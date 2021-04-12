#!/usr/bin/env bats

load "test_helper"

@test "index list" {
  local index=$(gen_name)
  run bin/elastic index create $index

  run bin/elastic index list
  assert_success
  assert_line $index
}

@test "index get" {
  local index=$(gen_name)
  run bin/elastic index create $index

  run bin/elastic index get $index
  assert_success
  assert_line $index
  refute_line "index_not_found_exception"
}

@test "index get (bad index)" {
  local index=$(gen_name)
  run bin/elastic index get $index
  assert_success
  assert_line "index_not_found_exception"
}

@test "index create" {
  local index=$(gen_name)
  local body='{"settings":{"index":{"refresh_interval":"1m"}},"mappings":{"properties":{"name":{"type":"keyword"}}}}'
  run bin/elastic index create $index $body
  assert_acknowledged

  run bin/elastic index get $index
  assert_line '"refresh_interval":"1m"'
  assert_line '"name":{"type":"keyword"'
}

@test "index delete" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic index get $index
  refute_line "index_not_found_exception"

  run bin/elastic index delete $index
  assert_acknowledged
  run bin/elastic index get $index
  assert_line "index_not_found_exception"
}

@test "index open and close" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic index list
  assert_line "open $index"

  run bin/elastic index close $index
  assert_success
  run bin/elastic index list
  assert_line "close $index"

  run bin/elastic index open $index
  assert_success
  run bin/elastic index list
  assert_line "open $index"
}
