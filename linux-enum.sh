#!/bin/bash

# Script         : linux-enum.sh
# Description    : Shell script for local enumeration on Linux.
# Author         : Kristof Toth - https://github.com/t0thkr1s
# Version        : 1.0

RED='\033[0;31m'
GREEN='\033[0;32m'
RST='\033[0m'

system_information() {

    kernel=`cat /proc/version 2>/dev/null`

    if [ "$kernel" ]; then
        echo -e "${GREEN}[ + ] Kernel information:${RST}\n$kernel\n"
    else
        uname=`uname -a 2>/dev/null`
        if [ "$uname" ]; then
            echo -e "${GREEN}[ + ] Kernel information:${RST}\n$uname\n"
        fi
    fi

    release=`cat /etc/*-release | grep DISTRIB 2>/dev/null`
    if [ "$release" ]; then
        echo -e "${GREEN}[ + ] Distribution information:${RST}\n$release\n"
    fi
    
    glibc_version=`ldd --version | head -n 1 2>/dev/null`
    if [ "$glibc_version" ]; then
        echo -e "${GREEN}[ + ] GNU C library information:${RST}\n$glibc_version\n"
    fi

}

user_information() {

    user_information=`id 2>/dev/null`
    if [ "$user_information" ]; then
        echo -e "${GREEN}[ + ] Current user & group information:${RST}\n$user_information\n" 
    fi

    previously_logged_in_users=`lastlog 2>/dev/null | grep -v "Never" 2>/dev/null`
    if [ "$previously_logged_in_users" ]; then
        echo -e "${GREEN}[ + ] Previously logged in users:${RST}\n$previously_logged_in_users\n"
    fi

    currently_logged_in_users=`w 2>/dev/null`
    if [ "$currently_logged_in_users" ]; then
        echo -e "${GREEN}[ + ] Currently logged in users:\e[00m\n$currently_logged_in_users\n"
    fi
    
    passwd_file=`cat /etc/passwd 2>/dev/null`
    if [ "$passwd_file" ]; then
        echo -e "${GREEN}[ + ] Contents of /etc/passwd:${RST}\n$passwd_file\n"
    else
        echo -e "${RED}[ - ] The /etc/passwd file is not readable!\n"
    fi

    shadow_file=`cat /etc/shadow 2>/dev/null`
    if [ "$shadow_file" ]; then
        echo -e "${GREEN}[ + ] Contents of /etc/shadow:${RST}\n$shadow_file\n"
    else
        echo -e "${RED}[ - ] The /etc/shadow file is not readable!\n"
    fi

}

main() {
    system_information
    user_information
}

main
