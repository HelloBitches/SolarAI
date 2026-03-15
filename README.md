# Solar AI Inverter - iOS App

SKYSAFE 品牌太陽能逆變器設定 APP，透過藍牙發現設備、WiFi 連接後以 HTTP API 獲取即時數據。

## 技術規格

- **語言**: Swift 5
- **框架**: UIKit (非 SwiftUI)
- **架構**: MVVM
- **最低 iOS 版本**: 15.0
- **方向**: 僅橫向 (Landscape)
- **通訊**: CoreBluetooth (BLE) + NEHotspotConfiguration (WiFi) + URLSession (HTTP)

## 專案結構

```
SolarAI/
├── project.yml                 # XcodeGen 專案配置
├── setup_assets.sh             # 圖片資源複製腳本
├── SolarAI/
│   ├── Application/            # AppDelegate, SceneDelegate, Info.plist
│   ├── Common/
│   │   ├── Constants.swift     # 全域常量、顏色、枚舉
│   │   ├── Extensions/         # UIColor+Hex, UIView+Layout
│   │   └── Utils/              # BitParser, DataFormatter
│   ├── Models/                 # API 回應模型、錯誤定義
│   ├── Services/               # NetworkService, BluetoothManager, WiFiManager
│   ├── Modules/
│   │   ├── Connection/         # 登入/藍牙掃描/WiFi 連接頁面
│   │   ├── Main/               # 主容器、側邊 Tab Bar、通用 UI
│   │   ├── General/            # 硬體狀態頁面 (圖標網格)
│   │   ├── StatusView/         # 能量流動圖 (動畫 + 即時數據)
│   │   ├── FaultyAlert/        # 故障警報頁面
│   │   └── Paygo/              # PAYGO 數字鍵盤頁面
│   ├── Resources/
│   │   ├── Assets.xcassets/    # 圖片資源目錄
│   │   └── LaunchScreen.storyboard
│   └── SolarAI.entitlements    # WiFi/Hotspot 權限
```

## 設定步驟

### 1. 複製圖片資源

確保 `/Users/lucky/Desktop/Solar资料` 資料夾存在，然後執行：

```bash
cd /Users/lucky/Desktop/SolarAI
bash setup_assets.sh
```

### 2. 生成 Xcode 專案

方式 A — 使用 XcodeGen（推薦）：

```bash
brew install xcodegen
cd /Users/lucky/Desktop/SolarAI
xcodegen generate
```

方式 B — 手動建立：

1. 打開 Xcode → File → New → Project → iOS App
2. Product Name: SolarAI, Language: Swift, Interface: Storyboard
3. 刪除自動生成的 ViewController.swift 和 Main.storyboard
4. 將 `SolarAI/` 資料夾拖入專案
5. 設定 Bundle Identifier: `com.skysafe.solarai`
6. 在 Signing & Capabilities 添加：
   - Access WiFi Information
   - Hotspot Configuration

### 3. 配置 Capabilities

在 Xcode 中添加以下 Capabilities：
- **Access WiFi Information** — 用於讀取當前 WiFi SSID
- **Hotspot Configuration** — 用於程式化連接 WiFi
- **Background Modes → Bluetooth Central** — 用於背景 BLE 掃描

### 4. Build & Run

在 Xcode 中選擇真機（需要真機測試 BLE 和 WiFi），然後 Build & Run。

## API 端點

| 方法 | 端點 | 說明 |
|------|------|------|
| GET | `/general.do` | 基本資訊 + 流動圖狀態 |
| GET | `/devStatus.do` | 設備即時狀態數據 |
| GET | `/faultyAlert.do` | 故障/警告位元資訊 |
| POST | `/password.do` | PAYGO 密碼驗證 |
| GET | `/showInfo.do` | PAYGO 設備狀態資訊 |

基地址: `http://192.168.4.1:8080`

## 注意事項

- BLE 和 WiFi 功能必須在**真機**上測試（模擬器不支援）
- 首次連接需授權藍牙和位置權限
- WiFi 密碼預設為 `SSE123456`
- 數據每 3 秒自動刷新
