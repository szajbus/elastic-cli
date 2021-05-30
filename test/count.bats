#!/usr/bin/env bats

load "test_helper"

@test "count" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic document insert $index 1 '{"name": "john wayne"}'
  run bin/elastic document insert $index 2 '{"name": "gregory peck"}'
  run bin/elastic index refresh $index

  run bin/elastic count $index
  assert_success
  assert_count 2
}

@test "count with query" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic document insert $index 1 '{"name": "john wayne"}'
  run bin/elastic document insert $index 2 '{"name": "gregory peck"}'
  run bin/elastic index refresh $index

  run bin/elastic count $index '{"query": {"match": {"name": "john"}}}'
  assert_success
  assert_count 1
}
