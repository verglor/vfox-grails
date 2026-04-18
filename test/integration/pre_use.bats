#!/usr/bin/env bats

load helper

@test "exact version match" {
    run bash -c "$VFOX_INIT && vfox use grails@6.1.2"
    [ "$status" -eq 0 ]
    [[ "$output" == *"6.1.2"* ]]
}

@test "major prefix resolves to latest installed" {
    run bash -c "$VFOX_INIT && vfox use grails@6"
    [ "$status" -eq 0 ]
    [[ "$output" == *"6.1.2"* ]]
}

@test "major.minor prefix resolves to latest installed" {
    run bash -c "$VFOX_INIT && vfox use grails@6.1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"6.1.2"* ]]
}

@test "major prefix resolves to latest installed across all series" {
    run bash -c "$VFOX_INIT && vfox use grails@7"
    [ "$status" -eq 0 ]
    [[ "$output" == *"7.0.7"* ]]
}

@test "uninstalled version fails with helpful message" {
    run bash -c "$VFOX_INIT && vfox use grails@99"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not installed"* ]]
}

