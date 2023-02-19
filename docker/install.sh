#!/bin/bash

pushd software
    printf "installing Linux daemon!\n"
    tar xf Linux_Licensing_Daemon.tar.Z
    printf "Done...\n"
    sleep 2s

    printf "installing libero SoC!\n"
    chmod +x Libero_SoC_v11.9_Linux.bin
    ./Libero_SoC_v11.9_Linux.bin
    printf "Done...\n"

    printf "installing libero softconsole!\n"
    chmod +x Microsemi-SoftConsole-v5.2.0.15-Linux-x86-Installer
    ./Microsemi-SoftConsole-v5.2.0.15-Linux-x86-Installer
    printf "Done...\n"
popd

