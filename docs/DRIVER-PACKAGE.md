# Driver package

V0.1 uses a complete Driver filesystem image.

Required layout:

```text
driver-manifest.json
SHA256SUMS
lib/
  modules/<kernel-release>/
  firmware/
```

`depmod` generates the standard Linux module dependency and alias indexes.

`driverctl` supports:

```text
driverctl status
driverctl list
driverctl scan
driverctl load <module>
driverctl unload <module>
driverctl info <module>
driverctl verify
```

Critical storage/root drivers should be switched through a reboot into a known
good release rather than hot-unloaded.
