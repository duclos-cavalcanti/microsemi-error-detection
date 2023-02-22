#!/bin/bash

export LM_LICENSE_FILE=1702@localhost
export SNPSLMD_LICENSE_FILE=1702@localhost
export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu/:/usr/lib

start_license() {
    pushd /home/docker/license
        Linux_Licensing_Daemon/lmdown -c License.dat -q
        Linux_Licensing_Daemon/lmgrd -c License.dat -log /tmp/lmgrd.log
    popd
    sleep 1s
}

start_libero() {
    pushd /home/docker/software
    popd
}

start_softconsole() {
    pushd /home/docker/software
    popd
}

main() {
    bash
    # start_license
    # start_libero
    # start_softconsole
}

main $@
