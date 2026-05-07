# Postcards iOS

Postcards iOS 客户端 —— 基于 SwiftUI + Combine 原生开发。

## 环境要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 项目结构

```
Postcards/
├── App/
│   ├── PostcardsApp.swift          # App 入口
│   └── ContentView.swift           # 根视图 (TabView)
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift         # API 客户端 (Combine)
│   │   └── KeychainService.swift   # 安全存储
│   ├── Persistence/
│   │   └── Models.swift            # SwiftData 模型
│   ├── Location/
│   │   └── LocationManager.swift   # 定位服务
│   ├── Media/
│   │   └── CameraService.swift     # 相机服务
│   └── AI/
│       └── (AI 服务封装)
├── Features/
│   ├── Home/                       # 首页
│   ├── Timeline/                   # 时间轴
│   ├── Map/                        # 地图
│   ├── Collection/                 # 收藏夹
│   ├── Profile/                    # 我的
│   └── Record/                     # 记录流程
├── DesignSystem/
│   ├── Colors/
│   │   └── PostcardColors.swift    # 品牌色系统
│   ├── Components/
│   │   ├── PostcardCard.swift      # 明信片卡片
│   │   └── FABButton.swift         # 悬浮按钮
│   ├── Typography/
│   ├── Animations/
│   └── ...
└── Resources/
    └── Assets.xcassets
```

## 架构模式

- **UI 层**: SwiftUI 声明式 UI
- **状态管理**: `@State`, `@StateObject`, `@Query` (SwiftData)
- **异步编程**: Combine 框架
- **数据持久化**: SwiftData (iOS 17+)
- **网络层**: Combine + URLSession

## 国内 SDK 集成清单

| SDK | 用途 | 集成阶段 |
|:---|:---|:---|
| 高德地图 SDK | 地图、轨迹、地理编码 | P0 |
| 极光推送 + 厂商通道 | 推送通知 | P0 |
| 微信 OpenSDK | 登录、分享、支付 | P0 |
| 支付宝 SDK | 支付 | P0 |
| 阿里云 OSS | 图片上传 | P0 |
| 阿里云 SLS | 日志上报 | P1 |
| 阿里云 ARMS | 性能监控 | P1 |
| 科大讯飞 SDK | 语音转文字 | P1 |

## 运行方式

### 方式一：Xcode 打开（推荐）

```bash
cd Postcards-iOS
open Package.swift  # 或直接用 Xcode 打开目录
```

### 方式二：命令行构建

```bash
cd Postcards-iOS
xcodebuild -scheme Postcards -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## 待办事项

- [ ] 接入高德地图 SDK 替换 MapKit
- [ ] 接入极光推送
- [ ] 接入微信登录 & 分享
- [ ] 接入阿里云 OSS 上传
- [ ] 接入科大讯飞语音转文字
- [ ] 接入国内大模型 API (通义千问/Kimi)
- [ ] 实现 3D 轨迹回放
- [ ] 实现明信片翻页动效
- [ ] 实现邮戳盖章动画
- [ ] Unit Tests 补充
- [ ] UI Tests 补充
