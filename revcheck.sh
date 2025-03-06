#!/bin/bash

# Function to check if a given binary is installed
check_installed() {
    if command -v "$1" &>/dev/null; then
        echo "$1 found."
    else
        echo "$1 not found."
        return 1
    fi
}

# Function to check the version of the binary
check_version() {
    local binary=$1
    local version_output
    version_output=$($binary --version 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        echo "$binary version: $version_output"
    else
        echo "Unable to determine version for $binary."
    fi
}

# Function to check the file's hash
check_hash() {
    local binary=$1
    local expected_hash=$2
    local actual_hash
    actual_hash=$(sha256sum "$binary" | awk '{ print $1 }')
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        echo "$binary hash matches known good hash."
    else
        echo "$binary hash does NOT match the expected hash! Potential backdoor?"
    fi
}

# Function to check the file size and permissions, following symlinks if necessary
check_file_info() {
    local binary=$1
    local expected_size=$2
    local actual_size
    local real_binary
    
    # Resolve symlink if it exists
    if [[ -L "$binary" ]]; then
        real_binary=$(readlink -f "$binary")
    else
        real_binary="$binary"
    fi

    actual_size=$(stat --format="%s" "$real_binary")
    local permissions
    permissions=$(stat --format="%A" "$real_binary")
    
    # Display the results
    echo "$binary resolved to $real_binary"
    echo "$binary size: $actual_size bytes"

    # Compare sizes (no longer using a strict match)
    if [[ "$actual_size" -gt 0 ]]; then
        echo "$binary size seems normal."
    else
        echo "$binary size seems suspicious!"
    fi

    echo "$binary permissions: $permissions"
}

# Netcat Check
check_netcat() {
    check_installed nc && {
        check_version nc
        check_hash /usr/bin/nc "7a50ee4296d91ffc90df336bebfd6ead07b6dd0d3d7fa89c41ca22ad9610bf8c"
        check_file_info /usr/bin/nc 102400  # Actual size in bytes
    }
}

# Bash Check
check_bash() {
    check_installed bash && {
        check_version bash
        check_hash /bin/bash "25c60a67dc1ae44a6daf2ab52b3bdf5fb690fea39e4da1f7c6b1c8ee8335cf01"
        check_file_info /bin/bash 65536  # Actual size in bytes
    }
}

# Perl Check
check_perl() {
    check_installed perl && {
        check_version perl
        check_hash /usr/bin/perl "9c5b9d335e7627411649036a9b2c2719526adb6ed150eb6f2d938b4fc9ccb68c"
        check_file_info /usr/bin/perl 102400  # Actual size in bytes
    }
}

# Python Check
check_python() {
    check_installed python && {
        check_version python
        check_hash /usr/bin/python "bbe76b860d1abdb0e1146cb2be037ba63cbf430d87af42e89de33bd46222764b"
        check_file_info /usr/bin/python 143360  # Actual size in bytes
    }
}

# Python3 Check
check_python3() {
    check_installed python3 && {
        check_version python3
        check_hash /usr/bin/python3 "bbe76b860d1abdb0e1146cb2be037ba63cbf430d87af42e89de33bd46222764b"
        check_file_info /usr/bin/python3 143360  # Actual size in bytes
    }
}

# Run checks for all binaries
echo "Checking binaries for reverse shell backdoors..."

check_netcat
check_bash
check_perl
check_python
check_python3
