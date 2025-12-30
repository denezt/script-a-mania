#!/bin/sh
# Run as root. Linux only.
# Fix: avoids cgcreate/cgexec on cgroup v2 systems (the common cause of:
# "One of the needed subsystems is not mounted").
# Strategy:
#   - If systemd is PID 1 and systemd-run exists: use it to apply CPU/memory limits (works on cgroup v2)
#   - Else if cgroup v1 + libcgroup tools exist: use cgcreate/cgexec (legacy path)
#   - Else: fail with a clear message

set -eux

ctndir='container-root'

die() {
  printf "\033[35mError:\t\033[31m%s\033[0m\n" "$1" >&2
  exit 1
}

[ "$(id -u)" -eq 0 ] || die "You must run this as root."
[ -d "$ctndir" ] || die "Missing ${ctndir} directory!"

cd "$ctndir"

# quick sanity checks for the chroot payload
[ -x "./bin/sh" ] || die "container-root is missing /bin/sh (expected at ${PWD}/bin/sh)."
# [ -x "./usr/bin/fish" ] || die "container-root is missing /usr/bin/fish (expected at ${PWD}/usr/bin/fish)."

uuid="cgroup_$(shuf -i 1000-2000 -n 1)"

# Detect cgroup version
cgroup_fs="$(stat -fc %T /sys/fs/cgroup 2>/dev/null || true)"   # cgroup2fs => v2

is_systemd=0
if [ -r /proc/1/comm ] && [ "$(cat /proc/1/comm)" = "systemd" ]; then
  is_systemd=1
fi

run_container() {
  # NOTE: We let unshare mount /proc for us (no duplicate proc mount).
  # Also bring up loopback, since we unshare network namespace.
  unshare -fmuipn --mount-proc \
    chroot "$PWD" \
    /bin/sh -lc \
    'ip link set lo up 2>/dev/null || true;
     hostname container-fun-times;
     exec /bin/sh'
}

cleanup_v1() {
  # Best-effort cleanup for cgroup v1
  cgdelete -g "cpu,cpuacct,memory:$uuid" 2>/dev/null || true
}

# ---- Preferred path: systemd-run (works cleanly on cgroup v2) ----
if [ "$cgroup_fs" = "cgroup2fs" ] && [ "$is_systemd" -eq 1 ] && command -v systemd-run >/dev/null 2>&1; then
  # CPUWeight: 1..10000 (100 is default). Use 512 as "medium-high" weight.
  # MemoryMax: bytes or human units. Use 1G as in the original.
  #
  # --collect makes the scope cleaned up after exit.
  systemd-run --quiet --scope --collect \
    -p "CPUWeight=512" \
    -p "MemoryMax=1G" \
    sh -lc "$(printf '%s\n' "$(command -v run_container >/dev/null 2>&1 || true)")" 2>/dev/null || true

  # The above "function export" trick is not portable in /bin/sh, so call directly:
  systemd-run --quiet --scope --collect \
    -p "CPUWeight=512" \
    -p "MemoryMax=1G" \
    sh -lc '
      set -eux
      cd "'"$PWD"'"
      unshare -fmuipn --mount-proc \
        chroot "'"$PWD"'" \
        /bin/sh -lc \
        '"'"'
        set -eux
        mkdir -p /proc
        mount -t proc proc /proc
        ip link set lo up 2>/dev/null || true;
        hostname container-fun-times;
        exec /bin/sh'"'"'
    '
  exit 0
fi

# ---- Legacy path: cgroup v1 with libcgroup tools ----
if [ "$cgroup_fs" != "cgroup2fs" ] && command -v cgcreate >/dev/null 2>&1 && command -v cgexec >/dev/null 2>&1; then
  trap cleanup_v1 EXIT INT TERM

  cgcreate -g "cpu,cpuacct,memory:$uuid"
  cgset -r cpu.shares=512 "$uuid"
  cgset -r memory.limit_in_bytes=1000000000 "$uuid"

  cgexec -g "cpu,cpuacct,memory:$uuid" \
    sh -lc '
      set -eux
      cd "'"$PWD"'"
      unshare -fmuipn --mount-proc \
        chroot "'"$PWD"'" \
        /bin/sh -lc \
        '"'"'ip link set lo up 2>/dev/null || true;
           hostname container-fun-times;
           exec /bin/sh'"'"'
    '

  exit 0
fi

# ---- If we got here, explain the real reason clearly ----
if [ "$cgroup_fs" = "cgroup2fs" ]; then
  die "Your system uses cgroup v2; cgcreate expects cgroup v1 subsystems. Install/use systemd-run (recommended) or switch to a cgroup-v2-native approach."
else
  die "cgroup v1 detected but libcgroup tools (cgcreate/cgexec) not available or controllers not mounted."
fi
