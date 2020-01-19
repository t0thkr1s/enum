#!/usr/bin/env bash

# Script         : linux-enum.sh
# Description    : Shell script for local enumeration on Linux.
# Author         : @t0thkr1s
# Version        : 1.0

RED='\033[0;31m'
GREEN='\033[0;32m'
RST='\033[0m'

system_information() {

    kernel=$(cat /proc/version 2>/dev/null)

    if [ "$kernel" ]; then
        echo -e "${GREEN}[ + ] Kernel information:${RST}\n$kernel\n"
    else
        uname=$(uname -a 2>/dev/null)
        if [ "$uname" ]; then
            echo -e "${GREEN}[ + ] Kernel information:${RST}\n$uname\n"
        fi
    fi

    release=$(cat /etc/*-release | grep DISTRIB 2>/dev/null)
    if [ "$release" ]; then
        echo -e "${GREEN}[ + ] Distribution information:${RST}\n$release\n"
    fi

}

user_information() {

    user_information=$(id 2>/dev/null)
    if [ "$user_information" ]; then
        echo -e "${GREEN}[ + ] Current user & group information:${RST}\n$user_information\n"
    fi

    previously_logged_in_users=$(lastlog 2>/dev/null | grep -v "Never" 2>/dev/null)
    if [ "$previously_logged_in_users" ]; then
        echo -e "${GREEN}[ + ] Previously logged in users:${RST}\n$previously_logged_in_users\n"
    fi

    currently_logged_in_users=$(w 2>/dev/null)
    if [ "$currently_logged_in_users" ]; then
        echo -e "${GREEN}[ + ] Currently logged in users:\e[00m\n$currently_logged_in_users\n"
    fi

    passwd_file=$(cat /etc/passwd 2>/dev/null)
    if [ "$passwd_file" ]; then
        echo -e "${GREEN}[ + ] Contents of /etc/passwd:${RST}\n$passwd_file\n"
    else
        echo -e "${RED}[ - ] The /etc/passwd file is not readable!\n"
    fi

    shadow_file=$(cat /etc/shadow 2>/dev/null)
    if [ "$shadow_file" ]; then
        echo -e "${GREEN}[ + ] Contents of /etc/shadow:${RST}\n$shadow_file\n"
    else
        echo -e "${RED}[ - ] The /etc/shadow file is not readable!\n"
    fi

    root_directory_permissions=$(ls -ahl /root/ 2>/dev/null)
    if [ "$root_directory_permissions" ]; then
        echo -e "${GREEN}[ + ] The /root directory is readable!${RST}\n$root_directory_permissions\n"
    fi

    home_directory_permissions=$(ls -ahl /home/ 2>/dev/null)
    if [ "$home_directory_permissions" ]; then
        echo -e "${GREEN}[ + ] Home directory permissions:${RST}\n$home_directory_permissions\n"
    fi

}

environmental_information() {

    enviroment_variables=$(env 2>/dev/null | grep -v 'LS_COLORS' 2>/dev/null)
    if [ "$enviroment_variables" ]; then
        echo -e "${GREEN}[ + ] Environment information:${RST}\n$enviroment_variables\n"
    fi

    selinux_status=$(sestatus 2>/dev/null)
    if [ "$selinux_status" ]; then
        echo -e "${GREEN}[ + ] SELinux seems to be present:${RST}\n$selinux_status\n"
    fi

    available_shells=$(tail -n +2 /etc/shells 2>/dev/null)
    if [ "$available_shells" ]; then
        echo -e "${GREEN}[ + ] Available shells:${RST}\n$available_shells\n"
    fi

}

service_information() {

    running_processes=$(ps aux 2>/dev/null)
    if [ "$running_processes" ]; then
        echo -e "${GREEN}[ + ] Running processes:${RST}\n$running_processes\n"
    fi

}

software_information() {

    glibc_version=$(ldd --version | head -n 1 2>/dev/null)
    if [ "$glibc_version" ]; then
        echo -e "${GREEN}[ + ] GNU C library information:${RST}\n$glibc_version\n"
    fi

    sudo_version=$(sudo -V 2>/dev/null | grep "Sudo version" 2>/dev/null)
    if [ "$sudo_version" ]; then
        echo -e "${GREEN}[ + ] Sudo version:${RST}\n$sudo_version\n"
    fi

    mysql_version=$(mysql --version 2>/dev/null)
    if [ "$mysql_version" ]; then
        echo -e "${GREEN}[ + ] Mysql version:${RST}\n$mysql_version\n"
    fi

    mysql_default=$(mysqladmin -uroot -proot version 2>/dev/null)
    if [ "$mysql_default" ]; then
        echo -e "${GREEN}[ + ] We can connect with the default (root:root) credentials!${RST}\n$mysql_default\n"
    fi

    mysql_nopassword=$(mysqladmin -uroot version 2>/dev/null)
    if [ "$mysql_nopassword" ]; then
        echo -e "${GREEN}[ + ] We can connect as 'root' without a password!${RST}\n$mysql_nopassword\n"
    fi

    postgres_version=$(psql -V 2>/dev/null)
    if [ "$postgres_version" ]; then
        echo -e "${GREEN}[ + ] Postgres version:${RST}\n$postgres_version\n"
    fi

    apache_version=$(
        apache2 -v 2>/dev/null
        httpd -v 2>/dev/null
    )
    if [ "$apache_version" ]; then
        echo -e "${GREEN}[ + ] Apache version:${RST}\n$apache_version\n"
    fi

    useful_software=$(command -v nmap aws nc ncat netcat nc.traditional wget curl ping gcc g++ make gdb base64 socat python python2 python3 python2.7 python2.6 python3.6 python3.7 perl php ruby xterm doas sudo fetch 2>/dev/null)
    if [ "$useful_software" ]; then
        echo -e "${GREEN}[ + ] Useful software:${RST}\n$useful_software\n"
    fi

}

file_information() {

    suid_files=$(find / -perm -4000 -type f -exec ls -la {} \; 2>/dev/null)
    if [ "$suid_files" ]; then
        echo -e "${GREEN}[ + ] SUID files:${RST}\n$suid_files\n"
    fi

    ssh_keys=$(grep -rl "PRIVATE KEY-----" /home 2>/dev/null)
    if [ "$ssh_keys" ]; then
        echo -e "${GREEN}[ + ] Private SSH keys found:${RST}\n$ssh_keys\n"
    fi

    aws_keys=$(grep -rli "aws_secret_access_key" /home 2>/dev/null)
    if [ "$aws_keys" ]; then
        echo -e "${GREEN}[ + ] AWS secret access keys found:${RST}\n$aws_keys\n"
    fi

    git_credentials=$(find / -name ".git-credentials" 2>/dev/null)
    if [ "$git_credentials" ]; then
        echo -e "${GREEN}[ + ] Git credentials found:${RST}\n$git_credentials\n"
    fi

    world_writable_files=$(find / ! -path "*/proc/*" ! -path "/sys/*" -perm -2 -type f -exec ls -la {} \; 2>/dev/null)
    if [ "$world_writable_files" ]; then
        echo -e "${GREEN}[ + ] World-writable files (excluding /proc and /sys):${RST}\n$world_writable_files\n"
    fi

    mails=$(ls -la /var/mail 2>/dev/null)
    if [ "$mails" ]; then
        echo -e "${GREEN}[ + ] Listing mails in /var/mail:${RST}\n$mails\n"
    fi

    gpg_keys=$(gpg --list-keys 2>/dev/null)
    if [ "$gpg_keys" ]; then
        echo -e "${GREEN}[ + ] GPG keys:${RST}\n$gpg_keys\n"
    fi

    ovpn_files=$(find / -name "*.ovpn" 2>/dev/null)
    if [ "$ovpn_files" ]; then
        echo -e "${GREEN}[ + ] OVPN files:${RST}\n$ovpn_files\n"
    fi

    vnc_directories=$(find /home / -type d -name .vnc 2>/dev/null)
    if [ "$vnc_directories" ]; then
        echo -e "${GREEN}[ + ] VNC directories:${RST}\n$vnc_directories\n"
    fi

}

container_information() {

    docker_container=$(
        grep -i docker /proc/self/cgroup 2>/dev/null
        find / -name "*dockerenv*" -exec ls -la {} \; 2>/dev/null
    )
    if [ "$docker_container" ]; then
        echo -e "${GREEN}[ + ] Looks like we are in a Docker container:${RST}\n$docker_container\n"
    fi

    lxc_container=$(grep -qa container=lxc /proc/1/environ 2>/dev/null)
    if [ "$lxc_container" ]; then
        echo -e "${GREEN}[ + ] Looks like we are in a LXC container:${RST}\n$lxc_container\n"
    fi

}

main() {
    system_information
    user_information
    environmental_information
    service_information
    software_information
    file_information
    container_information
}

main
