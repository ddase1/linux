# Boot protocol

Kernel command line parameters:

```text
driverdev=/dev/...
systemdev=/dev/...
diy.ci=1
```

Early userspace:

```text
mount proc/sys/devtmpfs
        ↓
mdev -s
        ↓
wait for Driver + System devices
        ↓
mount Driver read-only
        ↓
validate /lib/modules/$(uname -r)
        ↓
modprobe diy_hello
        ↓
mount System
        ↓
move Driver mount into new root
        ↓
switch_root
        ↓
/sbin/init
```

CI requires:

```text
DIY_DRIVER_DISK_OK
DIY_DRIVER_LOADED: diy_hello
DIY_SYSTEM_BOOT_OK
```
