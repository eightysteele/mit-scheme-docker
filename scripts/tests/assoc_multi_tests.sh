#!/bin/bash

oneTimeSetUp() {
    source ../assoc_multi.sh
}

suite() {
    suite_addTest test_assoc
    suite_addTest test_assoc_multiple_pairs
    suite_addTest test_set_duplicate_keys
    suite_addTest test_dissoc
    suite_addTest test_get
    suite_addTest test_contains
    suite_addTest test_size
    suite_addTest test_keys
}

test_set_duplicate_keys() {
    local result=""
    local result_str=""
    local key_name=""
    local -a map=()

    assoc_multi_clear map

    assoc_multi_set map \
          :key1 "initial_val1" \
          :key1 "final_val1" \
          :key2 "initial_val2" \
          :key2 "final_val2"
    $_ASSERT_TRUE_ $?
    assoc_multi_print map

    # Test for :key1, expecting the last value "final_val1"
    key_name=$(_assoc_multi_get_internal_key_name map :key1)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"initial_val1 final_val1"' '"$result_str"'

    eval "result=()"

    # Test for :key2, expecting the last value "final_val2"
    key_name=$(_assoc_multi_get_internal_key_name map :key2)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"initial_val2 final_val2"' '"$result_str"'

    # Test for the presence of all keys in the map
    result_str=$(assoc_multi_keys map)
    $_ASSERT_EQUALS_ '":key1 :key2"' "\"$result_str\""
}

test_assoc_multiple_pairs() {
    local result
    local key_name
    local -a map=()

    assoc_multi_clear map

    assoc_multi_set map :key1 "val1" :key2 "val2" :key3 "val3"
    $_ASSERT_TRUE_ $?

    assoc_multi_print map

    # Test for :key1
    key_name=$(_assoc_multi_get_internal_key_name map :key1)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"val1"' '"$result_str"'

    # Test for :key2
    key_name=$(_assoc_multi_get_internal_key_name map :key2)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"val2"' '"$result_str"'

    # Test for :key3
    key_name=$(_assoc_multi_get_internal_key_name map :key3)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"val3"' '"$result_str"'

    # Test for the presence of all keys in the map
    result_str=$(assoc_multi_keys map)
    $_ASSERT_EQUALS_ '":key1 :key2 :key3"' "\"$result_str\""
}

test_keys() {
    local result
    local -a map=()

    assoc_multi_clear map

    result=$(assoc_multi_keys map)
    $_ASSERT_EQUALS_ '""' "\"$result\""

    assoc_multi_set map :key1 "val1"
    assoc_multi_set map :key2 "val2"

    result=$(assoc_multi_keys map)
    $_ASSERT_EQUALS_ '":key1 :key2"' "\"$result\""
}

test_size() {
    local result
    local -a map=()

    assoc_multi_clear map

    assoc_multi_set map :key1 "val1"
    assoc_multi_set map :key2 "val2"

    # Test size of the map
    result=$(assoc_multi_size map)
    $_ASSERT_EQUALS_ '2' "$result"

    # Remove a key and test size again
    assoc_multi_remove map :key1
    result=$(assoc_multi_size map)
    $_ASSERT_EQUALS_ '1' "$result"
}

test_contains() {
    local result
    local -a map=()

    assoc_multi_clear map

    assoc_multi_set map :key1 "val1"

    # Test contains for an existing key
    assoc_multi_contains map :key1
    $_ASSERT_TRUE_ $?

    # Test contains for a non-existing key
    assoc_multi_contains map :key2
    $_ASSERT_FALSE_ $?
}

# Add more tests or setup if needed

test_assoc() {
    local result
    local key_name
    local -a map=()

    assoc_multi_clear map

    # Test adding a single value to a new key
    assoc_multi_set map :key1 "val1"
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key1)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    result="${key_name[*]}"
    $_ASSERT_EQUALS_ '"val1"' '"$result_str"'

    assoc_multi_clear map

    # Test adding multiple values to the same key
    assoc_multi_set map :key1 "val2"
    $_ASSERT_TRUE_ $?
    assoc_multi_set map :key1 "val3"
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key1)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"val2 val3"' '"$result_str"'

    assoc_multi_clear map

    # Test adding values to a different key
    assoc_multi_set map :key2 "val4"
    $_ASSERT_TRUE_ $?
    assoc_multi_set map :key2 "val5"
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key2)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"val4 val5"' '"$result_str"'

    # Test if the map array is updated correctly
    assoc_multi_set map :key3 "foo"
    assoc_multi_set map :key4 "bar"
    result_str="${map[*]}"
    $_ASSERT_EQUALS_ '":key2 :key3 :key4"' '"$result_str"'

    assoc_multi_clear map

    # Test adding a value with spaces
    val="a value with spaces"
    assoc_multi_set map :key3 "$val"
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key3)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ "\"$val\"" "\"$result_str\""

    assoc_multi_clear map

    # Test adding an empty value
    assoc_multi_set map :key4 ""
    key_name=$(_assoc_multi_get_internal_key_name map :key4)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '""' "\"$result_str\""

    assoc_multi_clear map

    # Test adding a numeric value
    assoc_multi_set map :key5 123
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key5)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '"123"' '"$result_str"'
}

test_dissoc() {
    local result
    local key_name
    local -a map=()

    assoc_multi_clear map

    # Setup: Add values to multiple keys
    assoc_multi_set map :key1 "val1"
    assoc_multi_set map :key1 "val2"
    assoc_multi_set map :key2 "val3"
    assoc_multi_set map :key3 "val4"

    # Test removing a key and its values
    assoc_multi_remove map :key1
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key1)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '""' '"$result_str"'

    # Test map array is updated correctly after removal
    result_str="${map[*]}"
    $_ASSERT_EQUALS_ '":key2 :key3"' '"$result_str"'

    # Test removing another key and its values
    assoc_multi_remove map :key2
    $_ASSERT_TRUE_ $?
    key_name=$(_assoc_multi_get_internal_key_name map :key2)
    eval "result=(\"\${$key_name[@]}\")"
    result_str="${result[*]}"
    $_ASSERT_EQUALS_ '""' '"$result_str"'

    # Test map array is updated correctly after second removal
    result_str="${map[*]}"
    $_ASSERT_EQUALS_ '":key3"' '"$result_str"'
}

test_get() {
    local result
    local key_name
    local -a map=()

    assoc_multi_clear map

    # Setup: Add values to multiple keys
    assoc_multi_set map :key1 "val1"
    assoc_multi_set map :key1 "val2"
    assoc_multi_set map :key2 "val3"

    # Test getting values for a key with multiple values
    result=$(assoc_multi_get map :key1)
    $_ASSERT_EQUALS_ '"val1 val2"' "\"$result\""

    # Test getting values for a key with a single value
    result=$(assoc_multi_get map :key2)
    $_ASSERT_EQUALS_ '"val3"' "\"$result\""

    # Test getting values for a non-existing key
    result=$(assoc_multi_get map :key3)
    $_ASSERT_EQUALS_ '""' "\"$result\""
}

. ./shunit2
