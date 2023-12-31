#!/bin/bash

oneTimeSetUp() {
    source ../assoc.sh
    #source ../common.sh
    #common_debug_enable "assoc.sh" "get"
}

suite() {
    suite_addTest test_assoc
    suite_addTest test_assoc_multiple_pairs
    suite_addTest test_assoc_overwrite_keys
    suite_addTest test_dissoc
    suite_addTest test_get
    suite_addTest test_contains
    suite_addTest test_size
    suite_addTest test_keys
}

test_assoc() {
    local result
    local -a map=()

    assoc_set map :key1 "val1"
    $_ASSERT_TRUE_ $?

    result=$(assoc_get map :key1)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '"val1"' "\"$result\""

    assoc_clear map
}

test_assoc_multiple_pairs() {
    local result
    local -a map=()

    assoc_set map :key1 "val1" :key2 "val2"
    $_ASSERT_TRUE_ $?

    result=$(assoc_get map :key1)
    $_ASSERT_EQUALS_ '"val1"' "\"$result\""

    result=$(assoc_get map :key2)
    $_ASSERT_EQUALS_ '"val2"' "\"$result\""

    assoc_clear map
}

test_assoc_overwrite_keys() {
    local result
    local -a map=()

    assoc_set map :key1 "initial_val1" :key1 "final_val1"
    $_ASSERT_TRUE_ $?

    result=$(assoc_get map :key1)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '"final_val1"' "\"$result\""

    assoc_clear map
}

test_dissoc() {
    local result
    local -a map=()

    assoc_set map :key1 "val1"
    assoc_remove map :key1
    $_ASSERT_TRUE_ $?

    result=$(assoc_get map :key1)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '""' "\"$result\""

    assoc_clear map
}

test_get() {
    local result
    local -a map1=()
    local -a map2=()

    assoc_set map1 :key1 "val1"
    assoc_set map2 :key2 "val2"

    result=$(assoc_get map1 :key1)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '"val1"' "\"$result\""

    result=$(assoc_get map2 :key2)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '"val2"' "\"$result\""

    assoc_clear map1
    assoc_clear map2
}

test_contains() {
    local -a map=()

    assoc_set map :key1 "val1"

    assoc_contains map :key1
    $_ASSERT_TRUE_ $?

    assoc_contains map :key2
    $_ASSERT_FALSE_ $?

    assoc_clear map
}

test_size() {
    local -a map=()
    local result

    assoc_set map :key1 "val1"
    assoc_set map :key2 "val2"
    result=$(assoc_size map)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '2' "$result"

    assoc_clear map
}

test_keys() {
    local result

    assoc_set map :key1 "val1"
    assoc_set map :key2 "val2"
    result=$(assoc_keys map)
    $_ASSERT_TRUE_ $?
    $_ASSERT_EQUALS_ '":key1 :key2"' "\"$result\""

    assoc_clear map
}

. ./shunit2
