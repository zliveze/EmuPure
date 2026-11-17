<div align="center">

# ⚡ EmuPure

**The Universal Android Emulator Debloater & Optimizer**  
*Zero Bloat. Zero Ads. Pure Performance for Mobile Gaming on PC.*

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-green.svg)]()
[![Emulator](https://img.shields.io/badge/emulators-MuMu%20%7C%20LDPlayer%20%7C%20BlueStacks%20%7C%20Nox-orange.svg)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()

[Tiếng Việt](README.vi.md) | **English**

</div>

---

## 🧐 Why EmuPure?

Android emulators like **MuMu Player**, **LDPlayer**, **BlueStacks**, and **Nox** are popular for mobile gaming and automation. However, out-of-the-box installations are notoriously bloated:
- **Aggressive Adware & Fake Icons**: Homescreens are injected with fake "Chrome" and "Download" buttons pointing to third-party APK URLs.
- **Background Telemetry & Payment SDKs**: Tracking services and Chinese payment gateways (Alipay, OAID, Easebar) run 24/7 in the background.
- **Resource Hogging**: Bloat services consume 300MB–500MB of unnecessary RAM and cause frame drops / micro-stutters during intensive gaming sessions.

**EmuPure** solves this in seconds. It connects via ADB, disables all bloatware packages, purges adware from the launcher database, binds custom ad-blocking hosts, and persists the clean environment across all reboots.

---

## 📊 Benchmark: Before vs After

| Metric | Before EmuPure | After EmuPure |
| :--- | :---: | :---: |
| **Idle Background RAM** | ~680 MB | **~350 MB (-48%)** |
| **Launcher Ad Shortcuts** | 5+ fake icons | **0 (Pure Stock Clean)** |
| **Telemetry & Ad Services** | 9 active services | **Disabled & Frozen** |
| **Ad Popups / Store Promos** | Frequent | **100% Blocked** |
| **Animation Latency** | 1.0x (sluggish) | **0.5x (Snappy & Responsive)** |
| **Reboot Persistence** | Bloat returns | **Permanently Protected** |

---

## ⚡ Quick Start (1-Line Command)

Open **PowerShell** (Run as Administrator recommended) and paste:

```powershell
irm https://raw.githubusercontent.com/zliveze/EmuPure/main/EmuPure.ps1 | iex
```

*Or clone the repository locally:*

```bash
git clone https://github.com/zliveze/EmuPure.git
cd EmuPure
powershell -ExecutionPolicy Bypass -File .\EmuPure.ps1
```

---

## 🎮 Supported Emulators

| Emulator | Status | Features |
| :--- | :---: | :--- |
| **MuMu Player 12 / Nx** | ✅ Fully Supported | Auto-ADB detection, Lawnchair ad purge, KernelSU persistence, Adblock hosts |
| **LDPlayer 9** | 🔄 In Progress | Flysilkworm adware freeze, Launcher cleanup |
| **BlueStacks 5** | 🔄 In Progress | Gamepedia & promo disabling, Telemetry blocker |
| **Nox Player** | 🔄 Planned | App Center removal, Ad domain blacklist |

---

## 🛠️ What EmuPure Does (MuMu Player Deep Dive)

1. **Auto-Detects ADB**: Finds MuMu’s internal `adb.exe` on port `16384` (or `7555`) and requests root privileges.
2. **Freezes Bloatware Packages**:
   - `com.mumu.store` *(MuMu App Store & pop-up pusher)*
   - `com.mumu.acc` *(MuMu Booster adware)*
   - `com.nemu.oaidmanager` *(Ad-tracking identifier)*
   - `com.mumu.shared.sdk` *(Alipay / external payment SDK hooks)*
   - `com.netease.mumu.cloner` *(Unnecessary cloner service)*
   - `com.android.adservices.api` *(Android 15 Privacy Sandbox tracking)*
   - `com.android.ondevicepersonalization.services`
   - `com.android.federatedcompute.services`

   > ⚠️ **NEVER disable `com.android.sdksandbox`** on Android 15: `PackageManagerService` requires exactly one SDK sandbox package at boot. Disabling it crash-loops `system_server` and **MuMu Player hangs forever at 98%**. EmuPure explicitly re-enables it on every run as a self-heal.
3. **Cleans Launcher Database**: Connects directly to SQLite `launcher_4_7_4_1.db` to remove fake Chrome/Amaze/Arknights promo shortcuts.
4. **Binds Ad-Blocking Hosts**: Redirects NetEase/MuMu ad servers (`easebar.com`, `mumuglobal.com`, `163.com`) to `0.0.0.0`.
5. **Boot Persistence (`/data/adb/service.d/debloat.sh`)**: Ensures optimizations automatically re-apply on every reboot.
6. **Windows Host Ad Block**: Provides `update-windows-hosts.bat` to block the Windows desktop client from downloading ads.

---

## 📁 Repository Structure

```text
EmuPure/
├── EmuPure.ps1                  # Master CLI with auto-emulator detection
├── MUMU_PROMPT_COPY_PASTE.md    # Ready-to-use prompt & copy-paste commands
├── README.md                    # English documentation
├── README.vi.md                 # Vietnamese documentation
├── scripts/
│   ├── debloat-mumu.ps1         # Dedicated MuMu Player debloater
│   ├── debloat-ldplayer.ps1     # LDPlayer 9 debloater
│   ├── debloat-bluestacks.ps1   # BlueStacks 5 debloater
│   ├── recover-stuck-mumu.py    # Rescue: MuMu stuck at 98% (Android 15)
│   └── update-windows-hosts.bat # Windows hosts ad blocker
├── configs/
│   ├── hosts.txt                # Consolidated emulator ad-block domain list
│   └── blocklist.json           # Package blocklists per emulator
└── LICENSE                      # MIT License
```

---

## 🚑 Rescue: MuMu stuck at 98%?

If MuMu Player hangs forever at 98% (Android 15), `com.android.sdksandbox` was
disabled — `system_server` cannot boot. While the VM is stuck, `adb shell pm
enable` does **not** work (PackageManagerService is dead). Run:

```bash
python scripts/recover-stuck-mumu.py
```

It re-enables the package via MuMu's `mumu-cli` (works even while stuck), then
restart MuMu Player and it will boot normally.

---

## 🤝 Contributing

Contributions are warmly welcomed! If you have optimized package lists or scripts for LDPlayer, BlueStacks, or Nox, please open a PR.

1. Fork the repo.
2. Create your feature branch (`git checkout -b feature/ldplayer-tuning`).
3. Commit your changes (`git commit -m 'Add LDPlayer 9 custom launcher cleaner'`).
4. Push to the branch (`git push origin feature/ldplayer-tuning`).
5. Open a Pull Request.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <b>Developed with ❤️ by <a href="https://github.com/zliveze">zliveze</a></b>
</div>

