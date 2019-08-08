#!/bin/bash

# Script         : linux-enum.sh
# Description    : Shell script for local enumeration on Linux.
# Author         : Kristof Toth - https://github.com/t0thkr1s
# Version        : 1.0

system_information() {

    proc_version=`cat /proc/version 2>/dev/null`

    if [ "$proc_version" ]; then
        echo -e "\e[00;31mKernel information:\e[00m\n$proc_version\n"
    else
        # try running uname
        uname=`uname -a 2>/dev/null`
        if [ "$uname" ]; then
            echo -e "\e[00;31mKernel information:\e[00m\n$uname\n"
        fi
    fi

    release=`cat /etc/*-release 2>/dev/null`
    if [ "$release" ]; then
        echo -e "\e[00;31mRelease information:\e[00m\n$release\n"
    fi

}

main() {
    system_information
}

main
