# joingewis kiosk

Minimal NixOS kiosk: boots straight into `cage` (Wayland compositor) running
Chromium fullscreen on <https://join.gewis.nl>. No desktop, no login manager.
Wi-Fi joins `iotroam`, falling back to `hotspot`, with PSKs from sops.

## Before a fresh install

1. Put your public SSH key(s) in `authorized_keys`. Without it the machine has
   no remote access (password auth is off).
2. Set the target disk in `disko.nix` (`/dev/sda`, `/dev/nvme0n1`, `/dev/vda`…).
   Check with `lsblk` on the target while it runs the installer ISO.
3. Stage the host age key so it lands at `/etc/sops/key` on first boot. Only
   needed when installing from scratch — for a machine already running NixOS,
   see "Updating a running kiosk" instead:

```bash
mkdir -p /tmp/kiosk-extra/etc/sops
cp /path/to/host-age-key /tmp/kiosk-extra/etc/sops/key
chmod 600 /tmp/kiosk-extra/etc/sops/key
```

## Install on a fresh machine

Boot the target from any NixOS installer ISO (join a network there so it is
reachable), make sure `sshd` is running and `root` is reachable, then:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#kiosk --extra-files /tmp/kiosk-extra --build-on remote root@<IP>
```

This partitions and formats the disk via disko, installs NixOS, and reboots
into the kiosk. It is destructive. `--build-on remote` is required from an
aarch64 Mac, which cannot build `x86_64-linux` locally.

Afterwards delete `/tmp/kiosk-extra` — it holds the host's private key.

## Updating a running kiosk

A machine that already runs NixOS needs no reinstall — put the age key in place
over SSH, then switch:

```bash
ssh root@<IP> mkdir -p /etc/sops
scp /path/to/host-age-key root@<IP>:/etc/sops/key
ssh root@<IP> chmod 600 /etc/sops/key

nixos-rebuild switch --flake .#kiosk \
  --target-host root@<IP> --build-host root@<IP>
```

`--build-host` points at the target because an aarch64 Mac cannot build
`x86_64-linux`. The first switch that introduces `/etc/sops/key` must have the
key already there, or `sops-install-secrets` fails and Wi-Fi stays down.
