#!/usr/bin/env bats

load helper

setup_file() {
    export AVAILABLE_VERSIONS
    AVAILABLE_VERSIONS=$(bash -c "$VFOX_INIT && vfox search grails" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -V)
}

teardown_file() {
    local preinstalled="3.3.13 6.1.2 7.0.7"
    local v
    for v in \
        "$(echo "$AVAILABLE_VERSIONS" | grep '^6\.' | tail -1)" \
        "$(echo "$AVAILABLE_VERSIONS" | tail -1)"; do
        [[ " $preinstalled " == *" $v "* ]] && continue
        bash -c "$VFOX_INIT && vfox uninstall grails@$v" 2>/dev/null || true
    done
}

@test "major prefix resolves to latest available" {
    run bash -c "$VFOX_INIT && vfox install grails@6"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$(echo "$AVAILABLE_VERSIONS" | grep '^6\.' | tail -1)"* ]]
}

@test "major.minor prefix resolves to latest available" {
    run bash -c "$VFOX_INIT && vfox install grails@6.1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$(echo "$AVAILABLE_VERSIONS" | grep '^6\.1\.' | tail -1)"* ]]
}

@test "latest resolves to highest available version" {
    run bash -c "$VFOX_INIT && vfox install grails@latest"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$(echo "$AVAILABLE_VERSIONS" | tail -1)"* ]]
}
