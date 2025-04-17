#!/usr/bin/env bats

load "test_helper"

@test "info" {
  run bin/elastic info
  assert_success
  assert_line "You Know, for Search"
}
