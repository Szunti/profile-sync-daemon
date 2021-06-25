TMP_DIR=/tmp/unshare_test

# save the PID of the process that keeps the namespace alive here
NS_ROOT_PID_FILE=$TMP_DIR/ns_root_pid

error() {
    echo $1
    exit 1
} >&2
