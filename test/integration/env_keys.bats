#!/usr/bin/env bats

load helper

setup() {
    bash -c "$VFOX_INIT && vfox use grails@6.1.2"
    eval "$(bash -c "$VFOX_INIT && vfox env -s bash")"
}

@test "GRAILS_HOME is set" {
    [ -n "$GRAILS_HOME" ]
}

@test "GRAILS_HOME points to existing directory" {
    [ -d "$GRAILS_HOME" ]
}

@test "PATH includes GRAILS_HOME/bin" {
    [[ ":$PATH:" == *":$GRAILS_HOME/bin:"* ]]
}

@test "grails binary is executable" {
    [ -x "$GRAILS_HOME/bin/grails" ]
}

@test "grails --version exits successfully" {
    run "$GRAILS_HOME/bin/grails" --version
    [ "$status" -eq 0 ]
}
