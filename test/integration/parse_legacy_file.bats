#!/usr/bin/env bats

load helper

@test ".sdkmanrc activates correct version" {
    run bash -c "$VFOX_INIT && tmpdir=\$(mktemp -d) && echo 'grails=6.1.2' > \$tmpdir/.sdkmanrc && cd \$tmpdir && eval \"\$(vfox env -s bash 2>/dev/null)\" && grep -q '6.1.2' \"\$GRAILS_HOME/bin/grails\""
    [ "$status" -eq 0 ]
}

@test ".grails-version activates correct version" {
    run bash -c "$VFOX_INIT && tmpdir=\$(mktemp -d) && echo '6.1.2' > \$tmpdir/.grails-version && cd \$tmpdir && eval \"\$(vfox env -s bash 2>/dev/null)\" && grep -q '6.1.2' \"\$GRAILS_HOME/bin/grails\""
    [ "$status" -eq 0 ]
}
