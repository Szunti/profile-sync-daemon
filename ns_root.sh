#!/usr/bin/bash

# This script runs inside the user namespace where we are root

SCRIPT_DIR=$(dirname $BASH_SOURCE)
. $SCRIPT_DIR/common.sh

# run command in nested namespace, map user to given uid and gid
run() {
    local NS_PID USERID GROUPID
    USERID=$1
    GROUPID=$2
    shift 2
    unshare --user --map-user=$USERID --map-group=$GROUPID $*
}

mount_overlay() {
    local TARGET LOWER UPPER WORKDIR
    TARGET=$TMP_DIR/$1
    LOWER=$2
    UPPER=${TARGET}_upper
    WORKDIR=${TARGET}_work
    mkdir $UPPER $WORKDIR $TARGET
    mount -t overlay overlaid \
          -olowerdir=$LOWER,upperdir=$UPPER,workdir=$WORKDIR $TARGET
}

unmount_overlay() {
    local TARGET
    TARGET=$TMP_DIR/$1
    umount $TARGET
    UPPER=${TARGET}_upper
    WORKDIR=${TARGET}_work
    rm -r $WORKDIR
    rmdir $UPPER $TARGET
}

COMMAND=$1
shift
$COMMAND $*
