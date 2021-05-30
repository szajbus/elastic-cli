#!/usr/bin/env bats

load "test_helper"

@test "search" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic document insert $index 1 '{"name": "john wayne"}'
  run bin/elastic document insert $index 2 '{"name": "gregory peck"}'
  run bin/elastic index refresh $index

  run bin/elastic search $index
  assert_success
  assert_total_hits 2
  assert_doc_found 1
  assert_doc_found 2
}

@test "search with query" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic document insert $index 1 '{"name": "john wayne"}'
  run bin/elastic document insert $index 2 '{"name": "gregory peck"}'
  run bin/elastic index refresh $index

  run bin/elastic search $index '{"query": {"match": {"name": "john"}}}'
  assert_success
  assert_total_hits 1
  assert_doc_found 1
}
