#!/bin/bash

install_license() {
    pushd /home/docker/license
        tar xf Linux_Licensing_Daemon.tar.Z
    popd
}

install_libero() {
    pushd /home/docker/software
        chmod +x Libero_SoC_v11.9_Linux.bin
        ./Libero_SoC_v11.9_Linux.bin
    popd
}

install_softconsole() {
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
