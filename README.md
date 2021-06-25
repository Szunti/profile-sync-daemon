# Example how to mount overlayfs without root permission in a user(+mount) namespace and run arbitrary commands in the user(+mount) namespace

First we create a user and mount namespace where we are mapped to root ie. have all capabilities.
To keep the namespace alive, we need a dummy process running (an infinite sleep loop).

```
./control.sh create_ns # mainly an unshare call
ps # this shows ns_dummy.sh and sleep running
```

The next command enters the namespace and creates an overlay on the test directory named `lower`. OVI is the target tag, this will be the name of the union directory, and can be used with unmount later

```
./control.sh mount_overlay OVI lower
```

This results in /tmp/unshare_test/OVI directory. The overlay fs should have the f1 file, but if we check OVI now, it's empty.

```
ls /tmp/unshare_test/OVI
```
Because we are now in the root mount namespace, to see the overlay filesystem, we need to enter the namespace it was mounted in.

So run a bash (this could be a firefox instead) in the mount namespace.

Because in the above created user namespace we have uid 0, this will create another nested namespace just to map us back to our original uid.
```
./control.sh run bash
(we are in nested namespace prompt)> ls /tmp/unshare_test/OVI
```
Now we can see the f1 file in OVI.

Cleanup
```
exit # leave the nested namespace
./control.sh unmount_overlay OVI
./control.sh kill_ns # this kills the dummy processes that pin the namespace
ps # should be only the shell and ps now
```

##Problems

`./control.sh run firefox` sees the overlayfs, but an unwrapped firefox doesn't.

One could replace the binary with a wrapper script, but that's a hack and would be overwritten on every system update.
Placing a wrapper earlier in PATH isn't robust either, e.g. the desktop file on my system gives the absolute path:
```
...
Exec=/usr/lib/firefox/firefox %u
...
```

This looks like a dead end to me.