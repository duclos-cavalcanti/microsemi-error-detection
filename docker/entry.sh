#!/bin/bash

export LM_LICENSE_FILE=1702@localhost
export SNPSLMD_LICENSE_FILE=1702@localhost
export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu/:/usr/lib

pushd /home/docker
    pushd software
        Linux_Licensing_Daemon/lmdown -c License.dat -q
        Linux_Licensing_Daemon/lmgrd -c License.dat -log /tmp/lmgrd.log

        pushd SoftConsole
            ./softconsole &
        popd

        pushd Libero
            ./libero &
        popd
    popd

    pushd repo
        bash
    popd
popd
