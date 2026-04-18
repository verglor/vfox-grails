#!/usr/bin/env bats

load helper

@test "lists versions without panic" {
    run bash -c "$VFOX_INIT && vfox search grails"
    [ "$status" -eq 0 ]
    [[ "$output" == *"7.0.7"* ]]
}

@test "lists versions across multiple major series" {
    run bash -c "$VFOX_INIT && vfox search grails"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3."* ]]
    [[ "$output" == *"6."* ]]
    [[ "$output" == *"7."* ]]
}
