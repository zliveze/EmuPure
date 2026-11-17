<div align="center">

# ⚡ EmuPure

**Bộ công cụ dọn dẹp & tối ưu hóa giả lập Android đa nền tảng**  
*Sạch bóng rác. Không quảng cáo. Tối đa FPS cho game thủ PC.*

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-green.svg)]()
[![Emulator](https://img.shields.io/badge/emulators-MuMu%20%7C%20LDPlayer%20%7C%20BlueStacks%20%7C%20Nox-orange.svg)]()

**Tiếng Việt** | [English](README.md)

</div>

---

## 🧐 Tại sao cần EmuPure?

Các trình giả lập phổ biến như **MuMu Player**, **LDPlayer**, **BlueStacks**, **Nox** khi cài đặt mặc định thường đi kèm rất nhiều "rác":
- **Quảng cáo & Ứng dụng giả mạo ngoài màn hình chính**: Nút bấm giả Chrome, link tải game tự động gán vào launcher.
- **Dịch vụ theo dõi & SDK thanh toán ngầm**: Các tiến trình thu thập dữ liệu (OAID, Easebar, Alipay) chạy nền liên tục.
- **Ngốn tài nguyên**: Chiếm dụng từ 300MB – 500MB RAM vô ích, gây giật lag (micro-stutter) và tụt khung hình (drop FPS) khi chơi các tựa game nặng (Genshin Impact, Honkai, Nikke, Arknights,...).

**EmuPure** giúp bạn xử lý toàn bộ vấn đề trên chỉ bằng một cú click chuột: Tự động kết nối ADB, đóng băng bloatware, làm sạch màn hình launcher, gắn Hosts chặn quảng cáo trên cả Windows lẫn Android và tự động bảo vệ qua mỗi lần khởi động lại.

---

## ⚡ Hướng dẫn sử dụng nhanh (1 Lệnh duy nhất)

Mở **PowerShell** trên Windows (khuyên dùng quyền Run as Administrator) và dán lệnh:

```powershell
irm https://raw.githubusercontent.com/zliveze/EmuPure/main/EmuPure.ps1 | iex
```

*Hoặc tải mã nguồn về máy:*

```bash
git clone https://github.com/zliveze/EmuPure.git
cd EmuPure
powershell -ExecutionPolicy Bypass -File .\EmuPure.ps1
```

---

## 🎮 Các giả lập hỗ trợ

| Giả lập | Trạng thái | Tính năng |
| :--- | :---: | :--- |
| **MuMu Player 12 / Nx** | ✅ Hoàn thiện | Tự phát hiện ADB, dọn sạch Launcher Lawnchair, ghim KernelSU, chặn Hosts |
| **LDPlayer 9** | 🔄 Đang hoàn thiện | Đóng băng Flysilkworm, dọn Launcher |
| **BlueStacks 5** | 🔄 Đang hoàn thiện | Tắt Gamepedia, chặn dịch vụ quảng cáo ngầm |
| **Nox Player** | 🔄 Dự kiến | Gỡ App Center, chặn domain quảng cáo |

---

## 🛠️ Chi tiết các tối ưu hóa trên MuMu Player

1. **Tự động nhận diện ADB**: Tìm kiếm `adb.exe` của MuMu trên cổng `16384` hoặc `7555` và tự động lấy quyền root.
2. **Đóng băng 9 ứng dụng & dịch vụ rác**:
   - `com.mumu.store` *(Cửa hàng MuMu Store)*
   - `com.mumu.acc` *(Bộ tăng tốc chứa quảng cáo)*
   - `com.nemu.oaidmanager` *(Dịch vụ định danh theo dõi người dùng)*
   - `com.mumu.shared.sdk` *(SDK thanh toán Alipay/NetEase)*
   - `com.netease.mumu.cloner` *(Trình nhân bản app)*
   - `com.android.adservices.api` *(Privacy Sandbox quảng cáo của Android 15)*
   - `com.android.ondevicepersonalization.services`
   - `com.android.federatedcompute.services`

   > ⚠️ **TUYỆT ĐỐI KHÔNG disable `com.android.sdksandbox`** trên Android 15: `PackageManagerService` yêu cầu đúng 1 SDK sandbox package khi khởi động. Disable nó sẽ khiến `system_server` crash loop và **MuMu Player kẹt vĩnh viễn ở 98%**. EmuPure tự bật lại package này mỗi lần chạy.
3. **Dọn sạch Database Launcher**: Kết nối SQLite `launcher_4_7_4_1.db` để xóa sạch các icon quảng cáo Chrome giả, Amaze giả và gợi ý tải game.
4. **Chặn Domain Quảng Cáo**: Trỏ toàn bộ domain telemetry (`easebar.com`, `mumuglobal.com`, `163.com`) về `0.0.0.0`.
5. **Duy trì tự động khi khởi động lại (`/data/adb/service.d/debloat.sh`)**: Tích hợp boot script của KernelSU để máy ảo luôn sạch bóng sau mỗi lần bật lại.
6. **Tối ưu tốc độ chuyển cảnh**: Thiết lập hệ số animation scale về `0.5x` giúp phản hồi tức thì, mượt mà tối đa khi vào game.

---

## 🚑 Cách cứu hộ khi MuMu kẹt 98%

Nếu MuMu Player đứng vĩnh viễn ở 98% (Android 15), nguyên nhân là `com.android.sdksandbox` đã bị disable khiến `system_server` không thể khởi động. Khi máy đang kẹt, `adb shell pm enable` **không có tác dụng** (PackageManagerService đã chết). Hãy chạy:

```bash
python scripts/recover-stuck-mumu.py
```

Script này bật lại package qua `mumu-cli` của MuMu (chạy được cả khi đang kẹt), sau đó tắt và mở lại MuMu Player là máy sẽ boot bình thường.

---

## 🤝 Đóng góp phát triển (Contributing)

Mọi đóng góp nhằm tối ưu danh sách package hoặc bổ sung các giả lập khác đều rất được hoan nghênh!

---

## 📄 Bản quyền (License)

Dự án phát hành dưới giấy phép MIT License.

---

<div align="center">
  <b>Phát triển bởi <a href="https://github.com/zliveze">zliveze</a></b>
</div>

