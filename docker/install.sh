#!/bin/bash

install_license() {
    printf "installing license daemon...\n"
    pushd /home/docker/license
        tar xf Linux_Licensing_Daemon.tar.Z
    popd
}

install_libero() {
    printf "installing libero...\n"
    pushd /home/docker/software
        chmod +x Libero_SoC_v11.9_Linux.bin
        TERM=xterm ./Libero_SoC_v11.9_Linux.bin -i silent
    popd
}

install_softconsole() {
    printf "installing softconsole...\n"
    pushd /home/docker/software
        chmod +x Microsemi-SoftConsole-v5.2.0.15-Linux-x86-Installer
        ./Microsemi-SoftConsole-v5.2.0.15-Linux-x86-Installer
    popd
}

main() {
    install_license
    install_libero
    install_softconsole
}

main $@
exit 0
