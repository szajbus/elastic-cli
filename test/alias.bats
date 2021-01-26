#!/usr/bin/env bats

load "test_helper"

@test "alias list" {
  local index=$(gen_name)
  local alias=$(gen_name)

  run elastic index create $index
  run elastic alias list
  assert_success
  refute_line $alias

  run elastic alias add $alias $index
  run elastic alias list
  assert_success
  assert_line $alias
}

@test "alias get" {
  local index=$(gen_name)
  local alias=$(gen_name)
  run elastic index create $index $body
  run elastic alias add $alias $index

  run elastic alias get $alias
  assert_success
  assert_line "{\"$index\":{\"aliases\":{\"$alias\""
}

@test "alias get (bad alias)" {
  local alias=$(gen_name)
  run elastic alias get $alias
  assert_line "alias [$alias] missing"
}

@test "alias add" {
  local index=$(gen_name)
  local alias=$(gen_name)
  local body='{"filter":{"term":{"name":"foo"}}}'
  run elastic index create $index
  run elastic alias add $alias $index $body
  assert_acknowledged

  run elastic alias get $alias
  assert_line '"filter":{"term":{"name":"foo"}}'
}

@test "alias delete" {
  local index=$(gen_name)
  local alias=$(gen_name)
  run elastic index create $index
  run elastic alias add $alias $index
  run elastic alias get $alias
  refute_line "alias [$alias] missing"

  run elastic alias delete $alias $index
  assert_acknowledged
  run elastic alias get $alias
  assert_line "alias [$alias] missing"
}

@test "alias switch" {
  local index1=$(gen_name)
  local index2=$(gen_name)
  local alias=$(gen_name)
  run elastic index create $index1
  run elastic index create $index2
  run elastic alias add $alias $index1

  run elastic alias get $alias
  assert_line "{\"$index1\":{\"aliases\":{\"$alias\""

  run elastic alias switch $alias $index1 $index2
  assert_acknowledged
  run elastic alias get $alias
  refute_line "{\"$index1\":{\"aliases\":{\"$alias\""
  assert_line "{\"$index2\":{\"aliases\":{\"$alias\""
}
