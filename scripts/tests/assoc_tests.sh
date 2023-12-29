#!/bin/bash

oneTimeSetUp() {
    source ../assoc.sh
}

setUp() {
    clear map
}

tearDown() {
    clear map
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

    assoc map :key1 "val1"
    $_ASSERT_TRUE_ $?

    # Test getting value for :key1
    result=$(get :key1)
    $_ASSERT_EQUALS_ '"val1"' "\"$result\""
}

test_assoc_multiple_pairs() {
    local result

    assoc map :key1 "val1" :key2 "val2"
    $_ASSERT_TRUE_ $?

    # Test getting value for :key1 and :key2
    result=$(get :key1)
    $_ASSERT_EQUALS_ '"val1"' "\"$result\""

    result=$(get :key2)
    $_ASSERT_EQUALS_ '"val2"' "\"$result\""
}

test_assoc_overwrite_keys() {
    local result

    # Add duplicate keys with different values
    assoc map :key1 "initial_val1" :key1 "final_val1"
    $_ASSERT_TRUE_ $?

    # Test for :key1, expecting the last value "final_val1"
    result=$(get :key1)
    $_ASSERT_EQUALS_ '"final_val1"' "\"$result\""
}

test_dissoc() {
    local result

    assoc map :key1 "val1"
    dissoc map :key1
    $_ASSERT_TRUE_ $?

    result=$(get :key1)
    $_ASSERT_EQUALS_ '""' "\"$result\""
}

test_get() {
    local result

    assoc map :key1 "val1"
    result=$(get :key1)
    $_ASSERT_EQUALS_ '"val1"' "\"$result\""
}

test_contains() {
    assoc map :key1 "val1"

    contains map :key1
    $_ASSERT_TRUE_ $?

    contains map :key2
    $_ASSERT_FALSE_ $?
}

test_size() {
    local result

    assoc map :key1 "val1"
    assoc map :key2 "val2"
    result=$(size map)
    $_ASSERT_EQUALS_ '2' "$result"
}

test_keys() {
    local result

    assoc map :key1 "val1"
    assoc map :key2 "val2"
    result=$(keys map)
    $_ASSERT_EQUALS_ '":key1 :key2"' "\"$result\""
}

. ./shunit2
