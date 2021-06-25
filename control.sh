#!/usr/bin/bash

# This is a script to control namespaces and overlay mounts

SCRIPT_DIR=$(dirname $BASH_SOURCE)
. $SCRIPT_DIR/common.sh

run_in_root_ns() {
    local NS_ROOT_PID
    NS_ROOT_PID=$(< $NS_ROOT_PID_FILE)
    nsenter --preserve-credentials \
            --user --mount \
            --root --wd \
            --target $NS_ROOT_PID $*
}

command_root_ns() {
    run_in_root_ns $SCRIPT_DIR/ns_root.sh $*
}

run() {
    command_root_ns run $(id -u) $(id -g) $*
}

# commands

create_ns() {
    local NS_ROOT_PID
    # create user namespace where we are root
    NS_ROOT_PID=$(unshare --user --mount -r $SCRIPT_DIR/ns_dummy.sh)
    echo $NS_ROOT_PID > $NS_ROOT_PID_FILE
}

kill_ns() {
    local NS_ROOT_PID

    NS_ROOT_PID=$(< $NS_ROOT_PID_FILE)
    kill $NS_ROOT_PID
    rm $NS_ROOT_PID_FILE
}

mount_overlay() {
    command_root_ns mount_overlay $*
}

unmount_overlay() {
    command_root_ns unmount_overlay $*
}

if [[ ! -d $TMP_DIR ]]; then
    mkdir $TMP_DIR
fi

COMMAND=$1
shift
$COMMAND $*
