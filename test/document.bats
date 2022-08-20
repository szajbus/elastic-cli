#!/usr/bin/env bats

load "test_helper"

@test "document insert, get, update, delete" {
  local index=$(gen_name)
  run bin/elastic index create $index

  run bin/elastic document insert $index 1 '{"name": "john wayne"}'
  run bin/elastic document get $index 1
  assert_line "john wayne"

  run bin/elastic document update $index 1 '{"doc": {"name": "gregory peck"}}'
  run bin/elastic document get $index 1
  assert_line "gregory peck"

  run bin/elastic document delete $index 1
  assert_line '"result":"deleted"'

  run bin/elastic document get $index 1
  assert_line '"found":false'
}

@test "document delete_by_query" {
  local index=$(gen_name)
  run bin/elastic index create $index

  run bin/elastic document insert $index 1 '{"name": "john wayne", "movie": "the shootist"}'
  run bin/elastic document insert $index 2 '{"name": "lauren bacall", "movie": "the shootist"}'
  run bin/elastic document insert $index 3 '{"name": "gregory peck", "movie": "cape fear"}'
  run bin/elastic index refresh $index

  run bin/elastic document delete_by_query $index '{"query": {"match": {"movie": "the shootist"}}}'
  assert_line '"deleted":2'
}

@test "document get (bad id)" {
  local index=$(gen_name)
  run bin/elastic index create $index

  run bin/elastic document get $index foo
  assert_line '"found":false'
}

@test "document upsert" {
  local index=$(gen_name)
  run bin/elastic index create $index

  run bin/elastic document upsert $index 1 '{"name": "john wayne"}'
  run bin/elastic document get $index 1
  assert_line "john wayne"
}

@test "document mget" {
  local index=$(gen_name)
  run bin/elastic index create $index
  run bin/elastic document insert $index 1 '{"name": "john wayne"}'
  run bin/elastic document insert $index 2 '{"name": "gregory peck"}'

  run bin/elastic document mget $index 1 2
  assert_line "john wayne"
  assert_line "gregory peck"
}

@test "document reindex" {
  local src=$(gen_name)
  local dest=$(gen_name)
  run bin/elastic index create $src
  run bin/elastic index create $dest
  run bin/elastic document insert $src 1 '{"name": "john wayne"}'
  run bin/elastic index refresh $src

  run bin/elastic document reindex $src $dest
  run bin/elastic document get $dest 1
  assert_line "john wayne"
}
