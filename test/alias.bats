#!/usr/bin/env bats

load "test_helper"

@test "alias list" {
  local index=$(gen_name)
  local alias=$(gen_name)

  run bin/elastic index create $index
  run bin/elastic alias list
  assert_success
  refute_line $alias

  run bin/elastic alias add $alias $index
  run bin/elastic alias list
  assert_success
  assert_line $alias
}

@test "alias get" {
  local index=$(gen_name)
  local alias=$(gen_name)
  run bin/elastic index create $index $body
  run bin/elastic alias add $alias $index

  run bin/elastic alias get $alias
  assert_success
  assert_line "{\"$index\":{\"aliases\":{\"$alias\""
}

@test "alias get (bad alias)" {
  local alias=$(gen_name)
  run bin/elastic alias get $alias
  assert_line "alias [$alias] missing"
}

@test "alias add" {
  local index=$(gen_name)
  local alias=$(gen_name)
  local body='{"filter":{"term":{"name":"foo"}}}'
  run bin/elastic index create $index
  run bin/elastic alias add $alias $index $body
  assert_acknowledged

  run bin/elastic alias get $alias
  assert_line '"filter":{"term":{"name":"foo"}}'
}

@test "alias delete" {
  local index=$(gen_name)
  local alias=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic alias add $alias $index
  run bin/elastic alias get $alias
  refute_line "alias [$alias] missing"

  run bin/elastic alias delete $alias $index
  assert_acknowledged
  run bin/elastic alias get $alias
  assert_line "alias [$alias] missing"
}

@test "alias switch" {
  local index1=$(gen_name)
  local index2=$(gen_name)
  local alias=$(gen_name)
  run bin/elastic index create $index1
  run bin/elastic index create $index2
  run bin/elastic alias add $alias $index1

  run bin/elastic alias get $alias
  assert_line "{\"$index1\":{\"aliases\":{\"$alias\""

  run bin/elastic alias switch $alias $index1 $index2
  assert_acknowledged
  run bin/elastic alias get $alias
  refute_line "{\"$index1\":{\"aliases\":{\"$alias\""
  assert_line "{\"$index2\":{\"aliases\":{\"$alias\""
}
