# 🚀 MuMu Player 12 / Nx - One-Click Debloat & Max Optimization Guide

> **Mục tiêu**: Loại bỏ 100% app rác, tắt quảng cáo ngầm, dọn sạch màn hình chính, ghim file Hosts chặn domain quảng cáo, giảm độ trễ (latency), tiết kiệm 300MB+ RAM và tối ưu FPS tối đa cho máy ảo Android.

---

## ⚡ CÁCH 1: LỆNH POWERSHELL 1 DÒNG (KHUYÊN DÙNG)

Mở **PowerShell** trên Windows và dán toàn bộ đoạn code dưới đây rồi bấm `Enter`. Hệ thống sẽ tự động tìm ADB, kết nối MuMu Player, gỡ sạch rác và tối ưu trong 3 giây:

```powershell
$adb = "D:\Program Files\Netease\MuMuPlayer\nx_device\15.0\shell\adb.exe"; if (-not (Test-Path $adb)) { $adb = "C:\Program Files\Netease\MuMuPlayer\nx_device\15.0\shell\adb.exe" }; & $adb connect 127.0.0.1:16384; & $adb -s 127.0.0.1:16384 root; Start-Sleep -s 1; @("com.mumu.store","com.mumu.acc","com.nemu.oaidmanager","com.mumu.shared.sdk","com.netease.mumu.cloner","com.android.adservices.api","com.android.ondevicepersonalization.services","com.android.federatedcompute.services","com.android.sdksandbox") | ForEach-Object { & $adb -s 127.0.0.1:16384 shell "pm disable-user --user 0 $_ 2>/dev/null; am force-stop $_ 2>/dev/null" }; & $adb -s 127.0.0.1:16384 shell "sqlite3 /data/data/app.lawnchair/databases/launcher_4_7_4_1.db \"DELETE FROM favorites WHERE intent LIKE '%easebar%' OR intent LIKE '%mumu.store%' OR intent LIKE '%Arknights%';\" 2>/dev/null; am force-stop app.lawnchair 2>/dev/null"; & $adb -s 127.0.0.1:16384 shell "mkdir -p /data/adb/service.d; echo '127.0.0.1 localhost`n::1 ip6-localhost`n0.0.0.0 mumu-global.fp.ps.easebar.com`n0.0.0.0 store-api.mumuglobal.com`n0.0.0.0 adl.easebar.com`n0.0.0.0 hub.mumuglobal.com`n0.0.0.0 notice.mumuglobal.com`n0.0.0.0 adlog.mumuglobal.com`n0.0.0.0 report.mumu.163.com`n0.0.0.0 api.mumu.163.com' > /data/adb/hosts; mount -o bind /data/adb/hosts /system/etc/hosts; echo '#!/system/bin/sh`nsleep 5`nmount -o bind /data/adb/hosts /system/etc/hosts`nfor p in com.mumu.store com.mumu.acc com.nemu.oaidmanager com.mumu.shared.sdk com.netease.mumu.cloner com.android.adservices.api; do pm disable-user --user 0 `$p; am force-stop `$p; done' > /data/adb/service.d/debloat.sh; chmod 755 /data/adb/service.d/debloat.sh; settings put global window_animation_scale 0.5; settings put global transition_animation_scale 0.5; settings put global animator_duration_scale 0.5"; Write-Host "`n[HOAN TAT] MuMu Player da duoc toi uu hoa sach se 100%!" -ForegroundColor Green
```

---

## 🛠️ CÁCH 2: CÁC BƯỚC THỦ CÔNG (ADB CLI)

Nếu bạn muốn chạy từng bước bằng lệnh ADB:

### Bước 1: Kết nối & Cấp quyền Root
```bash
adb connect 127.0.0.1:16384
adb -s 127.0.0.1:16384 root
```

### Bước 2: Vô hiệu hóa ứng dụng & dịch vụ rác
```bash
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.mumu.store
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.mumu.acc
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.nemu.oaidmanager
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.mumu.shared.sdk
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.netease.mumu.cloner
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.android.adservices.api
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.android.ondevicepersonalization.services
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.android.federatedcompute.services
adb -s 127.0.0.1:16384 shell pm disable-user --user 0 com.android.sdksandbox
```

### Bước 3: Dọn sạch icon quảng cáo ngoài màn hình chính (Lawnchair Launcher)
```bash
adb -s 127.0.0.1:16384 shell "sqlite3 /data/data/app.lawnchair/databases/launcher_4_7_4_1.db \"DELETE FROM favorites WHERE intent LIKE '%easebar%' OR intent LIKE '%mumu.store%' OR intent LIKE '%Arknights%';\""
adb -s 127.0.0.1:16384 shell am force-stop app.lawnchair
```

### Bước 4: Chặn domain quảng cáo MuMu trong Android Hosts
```bash
adb -s 127.0.0.1:16384 shell "cat << 'EOF' > /data/adb/hosts
127.0.0.1 localhost
::1 ip6-localhost
0.0.0.0 mumu-global.fp.ps.easebar.com
0.0.0.0 store-api.mumuglobal.com
0.0.0.0 adl.easebar.com
0.0.0.0 hub.mumuglobal.com
0.0.0.0 notice.mumuglobal.com
0.0.0.0 adlog.mumuglobal.com
0.0.0.0 report.mumu.163.com
0.0.0.0 api.mumu.163.com
EOF"

adb -s 127.0.0.1:16384 shell "mount -o bind /data/adb/hosts /system/etc/hosts"
```

### Bước 5: Cài đặt dịch vụ tự động duy trì khi khởi động lại (KernelSU)
```bash
adb -s 127.0.0.1:16384 shell "cat << 'EOF' > /data/adb/service.d/debloat.sh
#!/system/bin/sh
sleep 5
if [ -f /data/adb/hosts ]; then
    mount -o bind /data/adb/hosts /system/etc/hosts
fi
PACKAGES=\"com.mumu.store com.mumu.acc com.nemu.oaidmanager com.mumu.shared.sdk com.netease.mumu.cloner com.android.adservices.api com.android.ondevicepersonalization.services com.android.federatedcompute.services com.android.sdksandbox\"
for pkg in \$PACKAGES; do
    pm disable-user --user 0 \$pkg >/dev/null 2>&1
    am force-stop \$pkg >/dev/null 2>&1
done
if [ -f /data/data/app.lawnchair/databases/launcher_4_7_4_1.db ]; then
    sqlite3 /data/data/app.lawnchair/databases/launcher_4_7_4_1.db \"DELETE FROM favorites WHERE intent LIKE '%easebar%' OR intent LIKE '%mumu.store%' OR intent LIKE '%Arknights%';\" >/dev/null 2>&1
fi
EOF"

adb -s 127.0.0.1:16384 shell chmod 755 /data/adb/service.d/debloat.sh
```

### Bước 6: Giảm độ trễ chuyển cảnh (Animation Scale)
```bash
adb -s 127.0.0.1:16384 shell settings put global window_animation_scale 0.5
adb -s 127.0.0.1:16384 shell settings put global transition_animation_scale 0.5
adb -s 127.0.0.1:16384 shell settings put global animator_duration_scale 0.5
```

---

## 🛡️ CÁCH 3: CẬP NHẬT HOSTS TRÊN WINDOWS
Để chặn cả client MuMu Player trên Windows tải quảng cáo từ server NetEase:
1. Mở file `Update_Hosts_MuMu.bat` ngoài màn hình Desktop (hoặc chuột phải chọn **Run as administrator**).
2. Hoặc mở **Notepad với quyền Admin**, mở file `C:\Windows\System32\drivers\etc\hosts` và thêm vào cuối:
   ```text
   0.0.0.0 mumu-global.fp.ps.easebar.com
   0.0.0.0 store-api.mumuglobal.com
   0.0.0.0 adl.easebar.com
   0.0.0.0 hub.mumuglobal.com
   ```
3. Chạy lệnh: `ipconfig /flushdns`.
