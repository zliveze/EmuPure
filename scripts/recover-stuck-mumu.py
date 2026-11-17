#!/usr/bin/env python3
"""
EmuPure rescue tool: MuMu Player stuck at 98% on Android 15.

Root cause: com.android.sdksandbox was disabled (by old debloat scripts).
At boot, PackageManagerService.getRequiredSdkSandboxPackageName() throws
"There should exactly one sdk sandbox package; found 0" -> system_server
crash-loops -> MuMu Player loading screen hangs at 98% forever.

While system_server is dead, `adb shell pm enable` cannot work (pm talks to
the dead PackageManagerService). This tool edits the binary
/data/system/users/0/package-restrictions.xml directly via MuMu's mumu-cli
(which runs shell inside the guest independent of Android framework) and
flips the package's enabled flag back to 1.

Usage:
    python recover-stuck-mumu.py

Requirements: MuMu Player running (even if stuck at 98%), root enabled.
"""
import base64
import gzip
import os
import subprocess
import sys

CLI_CANDIDATES = [
    r'D:\Program Files\Netease\MuMuPlayer\nx_main\mumu-cli.exe',
    r'C:\Program Files\Netease\MuMuPlayer\nx_main\mumu-cli.exe',
]
CLI = next((p for p in CLI_CANDIDATES if os.path.exists(p)), None)
if CLI is None:
    sys.exit("mumu-cli.exe not found. Is MuMu Player installed?")

RESTRICTIONS = '/data/system/users/0/package-restrictions.xml'
# Binary attribute encoding of pkg "enabled" state, value 3 = disabled-user
ATTR_DISABLED = b'\xcf\x00\x06o\x00\x07\x00\x00\x00\x03'
ATTR_ENABLED = b'\xcf\x00\x06o\x00\x07\x00\x00\x00\x01'


def run_guest(cmd_str):
    res = subprocess.run([CLI, 'sh', '-v', '0', '-c', cmd_str],
                         capture_output=True, text=True)
    return res.returncode, res.stdout, res.stderr


def reenable(data, pkg_name):
    idx = data.find(pkg_name.encode())
    if idx == -1:
        print(f"  [skip] {pkg_name} not found in {RESTRICTIONS}")
        return data
    attr_idx = data.find(ATTR_DISABLED, idx, idx + 100)
    if attr_idx != -1:
        data[attr_idx + 9] = 1
        print(f"  [fixed] {pkg_name}: disabled(3) -> enabled(1)")
    elif data.find(ATTR_ENABLED, idx, idx + 100) != -1:
        print(f"  [ok] {pkg_name} already enabled")
    else:
        print(f"  [warn] {pkg_name}: no enabled-state attribute found nearby")
    return data


print(f"1. Fetching {RESTRICTIONS} via mumu-cli ...")
code, out, err = run_guest(f'cat {RESTRICTIONS} | gzip | base64')
if code != 0 or not out.strip():
    sys.exit(f"Failed to fetch: code={code}, err={err}")

data = bytearray(gzip.decompress(base64.b64decode(out.strip())))
print(f"   Read {len(data)} bytes.")

print("2. Re-enabling boot-critical packages ...")
for pkg in ('com.android.sdksandbox', 'com.mumu.shared.sdk'):
    data = reenable(data, pkg)

print("3. Writing back ...")
payload = base64.b64encode(gzip.compress(bytes(data))).decode('ascii')
cmd_write = (
    f"echo '{payload}' | base64 -d | gzip -d > {RESTRICTIONS}.new && "
    f"cp {RESTRICTIONS}.new {RESTRICTIONS} && "
    f"cp {RESTRICTIONS}.new {RESTRICTIONS}.reservecopy && "
    f"chown system:system {RESTRICTIONS}* && "
    f"chmod 660 {RESTRICTIONS}* && "
    f"rm {RESTRICTIONS}.new && "
    f"ls -l {RESTRICTIONS}"
)
code, out, err = run_guest(cmd_write)
print(f"   code={code}\n   stdout={out}\n   stderr={err}")
if code != 0:
    sys.exit("Write failed - do NOT reboot, retry this tool.")

print("4. Verifying ...")
code, out_verify, err = run_guest(f'cat {RESTRICTIONS} | gzip | base64')
vdata = gzip.decompress(base64.b64decode(out_verify.strip()))
v_sdk = vdata.find(b'com.android.sdksandbox')
print("   sdksandbox chunk:", vdata[v_sdk:v_sdk + 40])

print("\n[DONE] Now RESTART MuMu Player (close and reopen). It should boot past 98%.")
