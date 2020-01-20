#!/usr/bin/env bash

# Script         : linux-enum.sh
# Description    : Shell script for local enumeration on Linux.
# Author         : @t0thkr1s
# Version        : 1.0

banner="""
   __   _
  / /  (_)  ___  __ __ __ __ ____ ___   ___  __ __  __ _
 / /  / /  / _ \/ // / \ \ //___// -_) / _ \/ // / /  ' \\
/_/  /_/  /_//_/\_,_/ /_\_\      \__/ /_//_/\_,_/ /_/_/_/
"""

header="\n\e[1;97m---------- [ \e[1;96m %s \e[1;97m ] ----------\e[0m\n\n"
marker="\e[1;97m[ \e[1;92m+ \e[1;97m] %s \e[0m"

print_banner() {
    printf "\033c"
    printf "$banner"
}

system_information() {

    kernel=$(cat /proc/version 2>/dev/null)
    if [ "$kernel" ]; then
        printf "${header}" "KERNEL INFORMATION"
        echo "$kernel"
    else
        uname=$(uname -a 2>/dev/null)
        if [ "$uname" ]; then
            printf "${header}" "KERNEL INFORMATION"
            echo "$uname"
        fi
    fi

    release=$(cat /etc/*-release | grep DISTRIB 2>/dev/null)
    if [ "$release" ]; then
        printf "${header}" "DISTRIBUTION INFORMATION"
        echo "$release"
    fi
}

user_information() {

    user_information=$(id 2>/dev/null)
    if [ "$user_information" ]; then
        printf "${header}" "USER & GROUP INFORMATION"
        echo "$user_information"
    fi

    previously_logged_in_users=$(lastlog 2>/dev/null | grep -v "Never" 2>/dev/null)
    if [ "$previously_logged_in_users" ]; then
        printf "${header}" "PREVIOSULY LOGGED IN USERS"
        echo "$previously_logged_in_users"
    fi

    currently_logged_in_users=$(w 2>/dev/null)
    if [ "$currently_logged_in_users" ]; then
        printf "${header}" "CURRENTLY LOGGED IN USERS"
        echo "$currently_logged_in_users"
    fi

    passwd_file=$(cat /etc/passwd 2>/dev/null)
    if [ "$passwd_file" ]; then
        printf "${header}" "CONTENT OF THE PASSWD FILE"
        echo "$passwd_file"
    fi

    shadow_file=$(cat /etc/shadow 2>/dev/null)
    if [ "$shadow_file" ]; then
        printf "${header}" "CONTENT OF THE SHADOW FILE"
        echo "$shadow_file"
    fi

    sudoers_file=$(grep -v -e '^$' /etc/sudoers 2>/dev/null | grep -v "#" 2>/dev/null)
    if [ "$sudoers_file" ]; then
        printf "${header}" "CONTENT OF THE SUDOERS FILE"
        echo "$sudoers_file"
    fi

    root_directory_permissions=$(ls -ahl /root/ 2>/dev/null)
    if [ "$root_directory_permissions" ]; then
        printf "$marker" "The /root directory is readable!"
    fi

    home_directory_permissions=$(ls -ahl /home/ 2>/dev/null)
    if [ "$home_directory_permissions" ]; then
        printf "${header}" "HOME DIRECTORY PERMISSIONS"
        echo "$home_directory_permissions"
    fi

    sudo_without_password=$(echo '' | sudo -S -l -k 2>/dev/null)
    if [ "$sudo_without_password" ]; then
        printf "$marker" "We can sudo without a password!"
    fi

}

environmental_information() {

    enviroment_variables=$(env 2>/dev/null | grep -v 'LS_COLORS' 2>/dev/null)
    if [ "$enviroment_variables" ]; then
        printf "${header}" "ENVIRONMENT VARIABLES"
        echo "$enviroment_variables"
    fi

    selinux_status=$(sestatus 2>/dev/null)
    if [ "$selinux_status" ]; then
        printf "$marker" "SELinux seems to be present!"
    fi

    available_shells=$(tail -n +2 /etc/shells 2>/dev/null)
    if [ "$available_shells" ]; then
        printf "${header}" "AVAILABLE SHELLS"
        echo "$available_shells"
    fi

}

service_information() {

    running_processes=$(ps aux 2>/dev/null)
    if [ "$running_processes" ]; then
        printf "${header}" "RUNNING PROCESSES"
        echo "$running_processes"
    fi

}

software_information() {

    glibc_version=$(ldd --version | head -n 1 2>/dev/null)
    if [ "$glibc_version" ]; then
        printf "${header}" "GNU C LIBRARY INFORMATION"
        echo "$glibc_version"
    fi

    sudo_version=$(sudo -V 2>/dev/null | grep "Sudo version" 2>/dev/null)
    if [ "$sudo_version" ]; then
        printf "${header}" "SUDO VERSION"
        echo "$sudo_version"
    fi

    mysql_version=$(mysql --version 2>/dev/null)
    if [ "$mysql_version" ]; then
        printf "${header}" "MYSQL VERSION"
        echo "$mysql_version"
    fi

    mysql_default=$(mysqladmin -uroot -proot version 2>/dev/null)
    if [ "$mysql_default" ]; then
        printf "$marker" "Default MySQL credentials (root:root) are being used!"
    fi

    mysql_nopassword=$(mysqladmin -uroot version 2>/dev/null)
    if [ "$mysql_nopassword" ]; then
        printf "$marker" "The MySQL root user doesn't require a password!"
    fi

    postgres_version=$(psql -V 2>/dev/null)
    if [ "$postgres_version" ]; then
        printf "${header}" "POSTGRESQL VERSION"
        echo "$postgres_version"
    fi

    apache_version=$(
        apache2 -v 2>/dev/null
        httpd -v 2>/dev/null
    )
    if [ "$apache_version" ]; then
        printf "${header}" "APACHE VERSION"
        echo "$apache_version"
    fi

    useful_software=$(command -v nmap aws nc ncat netcat nc.traditional wget curl ping gcc g++ make gdb base64 socat python python2 python3 python2.7 python2.6 python3.6 python3.7 perl php ruby xterm doas sudo fetch 2>/dev/null)
    if [ "$useful_software" ]; then
        printf "${header}" "USEFUL SOFTWARE"
        echo "$useful_software"
    fi

}

file_information() {

    suid_files=$(find / -perm -4000 -type f -exec ls -la {} \; 2>/dev/null)
    if [ "$suid_files" ]; then
        printf "${header}" "SUID FILES"
        echo "$suid_files"
    fi

    git_credentials=$(find / -name ".git-credentials" 2>/dev/null)
    if [ "$git_credentials" ]; then
        printf "${header}" "GIT CREDENTIALS"
        echo "$git_credentials"
    fi

    world_writable_files=$(find / ! -path "*/proc/*" ! -path "/sys/*" ! -path "/var/lib/*" -perm -2 -type f -exec ls -la {} \; 2>/dev/null)
    if [ "$world_writable_files" ]; then
        printf "${header}" "WORLD-WRITABLE FILES"
        echo "$world_writable_files"
    fi

    mails=$(ls -la /var/mail 2>/dev/null)
    if [ "$(ls -A /var/mail)" ] && [ "$mails" ]; then
        printf "${header}" "MAILS"
        echo "$mails"
    fi

    gpg_keys=$(gpg --list-keys 2>/dev/null)
    if [ "$gpg_keys" ]; then
        printf "${header}" "GPG KEYS"
        echo "$gpg_keys"
    fi

    ovpn_files=$(find / -name "*.ovpn" 2>/dev/null)
    if [ "$ovpn_files" ]; then
        printf "${header}" "OVPN FILES"
        echo "$ovpn_files"
    fi

    vnc_directories=$(find / -type d -name ".vnc" 2>/dev/null)
    if [ "$vnc_directories" ]; then
        printf "${header}" "VNC DIRECTORIES"
        echo "$vnc_directories"
    fi

}

container_information() {

    docker_container=$(
        grep -i docker /proc/self/cgroup 2>/dev/null
        find / -name "*dockerenv*" -exec ls -la {} \; 2>/dev/null
    )
    if [ "$docker_container" ]; then
        printf "$marker" "It looks like we're in a Docker container!"
    fi

    lxc_container=$(grep -qa container=lxc /proc/1/environ 2>/dev/null)
    if [ "$lxc_container" ]; then
        printf "$marker" "It looks like we're in a LXC container!"
    fi

}

main() {
    print_banner
    system_information
    user_information
    environmental_information
    service_information
    software_information
    file_information
    container_information
}

main
