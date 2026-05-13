# Postcards — Code Wiki

> **项目**: Postcards（旅行明信片日记）
> **版本**: MVP
> **更新日期**: 2026-05-11
> **仓库路径**: `/Users/fanghua/code/Postcards`

---

## 目录

1. [项目概述](#1-项目概述)
2. [整体架构](#2-整体架构)
3. [项目结构](#3-项目结构)
4. [iOS 客户端 (SwiftUI)](#4-ios-客户端-swiftui)
5. [HarmonyOS 客户端 (ArkTS)](#5-harmonyos-客户端-arkts)
6. [核心数据模型](#6-核心数据模型)
7. [关键类与函数说明](#7-关键类与函数说明)
8. [设计系统](#8-设计系统)
9. [依赖关系](#9-依赖关系)
10. [项目运行方式](#10-项目运行方式)
11. [文档与规范](#11-文档与规范)

---

## 1. 项目概述

Postcards 是一款智能旅行日志工具，让用户通过"明信片"的形式记录旅行中的美好瞬间。核心功能包括：拍照记录、时间轴浏览、地图足迹展示、旅行管理和分享卡片生成。

**目标平台**: iOS 17+ (优先)、HarmonyOS (并行开发)
**架构模式**: 声明式 UI + 本地数据持久化 + 后端 API 预留
**当前阶段**: MVP（最小可行产品），使用本地 Mock 数据

---

## 2. 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        客户端层                              │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │  iOS App            │  │  HarmonyOS App              │  │
│  │  SwiftUI + Combine  │  │  ArkTS + ArkUI              │  │
│  │  SwiftData 本地持久化 │  │  Preferences 本地持久化      │  │
│  └─────────────────────┘  └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (预留)
┌─────────────────────────────────────────────────────────────┐
│                     阿里云 API 网关                          │
│              JWT 认证 · 限流 · 请求路由                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (预留)
┌─────────────────────────────────────────────────────────────┐
│                     后端服务层 (Go/Gin)                      │
│  ┌──────────────┐  ┌─────────────────────────────────────┐ │
│  │ User Service │  │      Travel Service                  │ │
│  │ 用户+认证+短信 │  │  旅行+明信片+媒体+地图+分享+AI规则筛选 │ │
│  └──────────────┘  └─────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (预留)
┌─────────────────────────────────────────────────────────────┐
│                      数据层                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ PostgreSQL  │  │    Redis    │  │   阿里云 OSS + CDN  │ │
│  │ 关系数据     │  │   缓存+Geo   │  │    图片存储+加速      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 项目结构

```
Postcards/
├── Postcards-iOS/                    # iOS 客户端 (SwiftUI)
│   ├── Postcards/
│   │   ├── App/                      # App 入口
│   │   │   ├── PostcardsApp.swift    # @main 入口，SwiftData 容器初始化
│   │   │   └── ContentView.swift     # 根视图，5 Tab 导航
│   │   ├── Core/                     # 核心基础设施
│   │   │   ├── Network/              # 网络层
│   │   │   │   ├── APIClient.swift   # Combine 网络客户端
│   │   │   │   └── KeychainService.swift # Token 安全存储
│   │   │   ├── Location/             # 定位服务
│   │   │   │   └── LocationManager.swift # CoreLocation 封装
│   │   │   ├── Media/                # 媒体服务
│   │   │   │   └── CameraService.swift   # AVFoundation 相机
│   │   │   └── Persistence/          # 数据持久化
│   │   │       ├── Models.swift      # SwiftData 模型定义
│   │   │       ├── LocalMediaStore.swift # 本地图片存储
│   │   │       └── MockBackendSeeder.swift # Mock 数据种子
│   │   ├── DesignSystem/             # 设计系统
│   │   │   ├── Colors/
│   │   │   │   └── PostcardColors.swift  # 品牌色系统
│   │   │   └── Components/           # 可复用组件
│   │   │       ├── PostalVisualSystem.swift  # 邮票/邮戳视觉组件
│   │   │       ├── PostcardCard.swift        # 明信片卡片
│   │   │       ├── FABButton.swift           # 悬浮按钮
│   │   │       ├── StampElements.swift       # 邮票元素
│   │   │       ├── TravelFilterChips.swift   # 旅行筛选器
│   │   │       └── TravelCoverImage.swift    # 旅行封面图
│   │   ├── Features/                 # 功能模块
│   │   │   ├── Home/                 # 首页
│   │   │   │   ├── HomeView.swift    # 首页主视图
│   │   │   │   └── TravelDetailView.swift # 旅行详情
│   │   │   ├── Timeline/             # 时间轴
│   │   │   │   └── TimelineView.swift
│   │   │   ├── Map/                  # 地图
│   │   │   │   └── MapView.swift     # MapKit 地图足迹
│   │   │   ├── Collection/           # 收藏夹
│   │   │   │   └── CollectionView.swift
│   │   │   ├── Profile/              # 个人中心
│   │   │   │   └── ProfileView.swift
│   │   │   └── Record/               # 记录流程
│   │   │       └── RecordFlowView.swift # 拍照→编辑→预览→保存
│   │   └── Resources/                # 资源文件
│   ├── PostcardsTests/               # 单元测试
│   ├── PostcardsUITests/             # UI 测试
│   └── Package.swift                 # Swift Package Manager
│
├── Postcards-Harmony/                # HarmonyOS 客户端 (ArkTS)
│   ├── entry/
│   │   └── src/main/ets/
│   │       ├── entryability/
│   │       │   └── EntryAbility.ets  # Ability 入口
│   │       ├── model/                # 数据模型与管理
│   │       │   ├── DataManager.ets   # 全局数据管理器 (Preferences)
│   │       │   ├── Travel.ets        # 旅行实体
│   │       │   ├── Postcard.ets      # 明信片实体
│   │       │   ├── UserStats.ets     # 用户统计
│   │       │   └── MockBackendSeeder.ets # Mock 数据
│   │       ├── components/           # 可复用组件
│   │       │   ├── Colors.ets        # 品牌色
│   │       │   ├── PostalComponents.ets  # 邮政视觉组件
│   │       │   ├── PostcardCard.ets      # 明信片卡片
│   │       │   └── TravelFilterChips.ets # 旅行筛选
│   │       ├── pages/                # 页面
│   │       │   ├── Index.ets         # 根页面 (Tab 导航)
│   │       │   ├── HomeView.ets      # 首页
│   │       │   ├── TimelineView.ets  # 时间轴
│   │       │   ├── MapView.ets       # 地图
│   │       │   ├── CollectionView.ets # 收藏
│   │       │   ├── ProfileView.ets   # 个人中心
│   │       │   └── RecordPage.ets    # 记录页面
│   │       └── utils/
│   │           └── UUIDUtil.ets      # UUID 生成工具
│   └── ... (HarmonyOS 工程配置)
│
└── [产品文档]/                        # PRD/架构/设计文档
    ├── Postcards_PRD_v2.md           # 产品需求文档
    ├── Postcards_技术架构设计.md      # 技术架构设计
    ├── Postcards_架构任务分解_v1.md   # 任务分解
    ├── Postcards_设计规范与设计语言.md # 设计规范
    └── ...
```

---

## 4. iOS 客户端 (SwiftUI)

### 4.1 技术栈

| 层级 | 技术选型 | 说明 |
|:---|:---|:---|
| UI 框架 | SwiftUI | 声明式 UI，iOS 17+ |
| 状态管理 | `@State`, `@StateObject`, `@Query` (SwiftData) | 响应式数据绑定 |
| 异步编程 | Combine | 事件驱动异步流 |
| 数据持久化 | SwiftData | Apple 原生 ORM，自动迁移 |
| 网络 | URLSession + Combine | 预留后端 API 接入 |
| 本地存储 | FileManager | 图片本地存储 (ApplicationSupport) |
| 安全 | Security.framework (Keychain) | Token 安全存储 |

### 4.2 模块职责

#### App 层

| 文件 | 职责 |
|:---|:---|
| `PostcardsApp.swift` | App 入口，初始化 SwiftData ModelContainer，注入 Mock 数据 |
| `ContentView.swift` | 根视图，管理 5 个 Tab (首页/时间轴/地图/收藏/我的)，自定义 PostalTabBar |

#### Core 层

| 模块 | 文件 | 职责 |
|:---|:---|:---|
| Network | `APIClient.swift` | 基于 Combine 的通用 HTTP 客户端，支持 JWT Token 自动附加、通用错误处理、Endpoint 构建器 |
| Network | `KeychainService.swift` | 封装 Security.framework，安全存储 accessToken / refreshToken |
| Location | `LocationManager.swift` | CoreLocation 封装，支持权限申请、单次定位请求、逆地理编码 (Combine 流) |
| Media | `CameraService.swift` | AVFoundation 相机封装，支持预览、拍照、前后摄像头切换 (Combine 流) |
| Persistence | `Models.swift` | SwiftData `@Model` 定义：Travel、Postcard、UserStats |
| Persistence | `LocalMediaStore.swift` | 本地图片存储，JPEG 压缩 (quality 0.85)，跨平台兼容 (UIKit/AppKit) |
| Persistence | `MockBackendSeeder.swift` | MVP 阶段 Mock 数据注入 |

#### Features 层

| 模块 | 文件 | 职责 |
|:---|:---|:---|
| Home | `HomeView.swift` | 首页：当前旅行卡片、旅行切换器、地图预览统计、FAB 按钮 |
| Home | `TravelDetailView.swift` | 旅行详情页 |
| Timeline | `TimelineView.swift` | 时间轴：按日期分组瀑布流、旅行筛选、搜索 |
| Map | `MapView.swift` | 地图足迹：MapKit 标注、城市邮戳标记、旅行轨迹连线、统计栏 |
| Collection | `CollectionView.swift` | 收藏夹：星标明信片展示 |
| Profile | `ProfileView.swift` | 个人中心：用户统计、设置 |
| Record | `RecordFlowView.swift` | 记录流程：选择方式→拍照/相册→编辑→预览→保存 |

---

## 5. HarmonyOS 客户端 (ArkTS)

### 5.1 技术栈

| 层级 | 技术选型 | 说明 |
|:---|:---|:---|
| UI 框架 | ArkUI (声明式 UI) | ArkTS 语法 |
| 状态管理 | `@State`, `@Link`, `@Prop` | 组件状态绑定 |
| 数据持久化 | `@kit.ArkData` (preferences) | 键值对本地存储 |
| 导航 | `@ohos.router` | 页面路由 |

### 5.2 模块职责

| 模块 | 文件 | 职责 |
|:---|:---|:---|
| Entry | `EntryAbility.ets` | Ability 生命周期管理，初始化 DataManager |
| Model | `DataManager.ets` | 全局数据管理器，Preferences 读写，Travel/Postcard CRUD |
| Model | `Travel.ets` | 旅行实体类，含序列化/反序列化 |
| Model | `Postcard.ets` | 明信片实体类，含序列化/反序列化 |
| Model | `UserStats.ets` | 用户统计实体 |
| Model | `MockBackendSeeder.ets` | Mock 数据种子 |
| Pages | `Index.ets` | 根页面，5 Tab 导航 |
| Pages | `HomeView.ets` | 首页：当前旅行卡片、旅行切换器、统计预览 |
| Pages | `TimelineView.ets` | 时间轴浏览 |
| Pages | `MapView.ets` | 地图足迹 |
| Pages | `RecordPage.ets` | 记录流程 |
| Components | `Colors.ets` | 品牌色常量 |
| Components | `PostalComponents.ets` | 邮政视觉系统组件 |
| Components | `PostcardCard.ets` | 明信片卡片组件 |
| Utils | `UUIDUtil.ets` | UUID 生成工具 |

---

## 6. 核心数据模型

### 6.1 Travel (旅行)

```swift
// iOS (SwiftData)
@Model
final class Travel {
    @Attribute(.unique) var id: UUID
    var title: String           // 旅行标题
    var destination: String     // 目的地
    var startDate: Date         // 开始日期
    var endDate: Date?          // 结束日期 (可选)
    var status: TravelStatus    // 状态: ongoing / completed / planned
    var isCurrent: Bool         // 是否为当前旅行
    var coverImageURL: String?  // 封面图路径
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Postcard.travel)
    var postcards: [Postcard]?  // 关联明信片 (级联删除)
}
```

```typescript
// HarmonyOS
class Travel {
    id: string;                 // UUID
    title: string;
    destination: string;
    startDate: number;          // timestamp
    endDate: number | null;
    status: TravelStatus;       // 'ONGOING' | 'COMPLETED' | 'PLANNED'
    isCurrent: boolean;
    coverImageURL: string | null;
    createdAt: number;
    updatedAt: number;
}
```

### 6.2 Postcard (明信片)

```swift
// iOS (SwiftData)
@Model
final class Postcard {
    @Attribute(.unique) var id: UUID
    var travelID: UUID?         // 关联旅行 ID
    var photos: [String]        // 本地图片路径数组
    var locationName: String    // 地点名称
    var locationLat: Double?    // 纬度
    var locationLng: Double?    // 经度
    var country: String?        // 国家
    var city: String?           // 城市
    var recordedAt: Date        // 记录时间
    var weatherCondition: String? // 天气状况
    var weatherTemp: Double?    // 温度
    var note: String?           // 文字备注
    var tags: [String]          // 标签数组
    var isFavorite: Bool        // 是否收藏
    var createdAt: Date
    @Relationship
    var travel: Travel?         // 关联旅行对象
}
```

### 6.3 UserStats (用户统计)

```swift
@Model
final class UserStats {
    var totalCities: Int        // 到访城市数
    var totalPostcards: Int     // 明信片总数
    var totalCountries: Int     // 到访国家数
    var joinedDays: Int         // 使用天数
}
```

---

## 7. 关键类与函数说明

### 7.1 iOS — APIClient

```swift
final class APIClient {
    static let shared: APIClient           // 单例
    
    // 通用请求 (Combine)
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError>
    
    // 文件上传 (预留)
    func upload(file: URL, endpoint: Endpoint) -> AnyPublisher<MediaUploadResponse, APIError>
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: [String: Any]?
    
    // 预定义端点
    static func travels() -> Endpoint
    static func createTravel(title:destination:startDate:) -> Endpoint
    static func postcards(travelID:) -> Endpoint
    static func createPostcard(travelID:location:note:) -> Endpoint
    static func userStats() -> Endpoint
}
```

### 7.2 iOS — LocationManager

```swift
final class LocationManager: NSObject, ObservableObject {
    static let shared: LocationManager
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocation?
    @Published var placemark: CLPlacemark?
    
    func requestPermission()                           // 申请定位权限
    func requestSingleLocation() -> AnyPublisher<CLLocation, Error>      // 单次定位
    func reverseGeocode(_ location: CLLocation) -> AnyPublisher<CLPlacemark, Error> // 逆地理编码
}
```

### 7.3 iOS — CameraService

```swift
final class CameraService: NSObject, ObservableObject {
    @Published var session: AVCaptureSession
    @Published var isReady: Bool
    @Published var error: CameraError?
    
    func checkPermission() -> AnyPublisher<Bool, Never>     // 检查/申请相机权限
    func setup()                                             // 初始化相机会话
    func capturePhoto() -> AnyPublisher<UIImage, CameraError> // 拍照
    func stop()                                              // 停止会话
    func switchCamera()                                      // 切换前后摄像头
}
```

### 7.4 iOS — KeychainService

```swift
final class KeychainService {
    static let shared: KeychainService
    
    var accessToken: String? { get set }   // Keychain 读写
    var refreshToken: String? { get set }
    
    func clear()                            // 清除所有 Token
}
```

### 7.5 iOS — LocalMediaStore

```swift
enum LocalMediaStore {
    // 保存图片到本地，返回文件路径数组
    static func save(images: [StoredPlatformImage]) throws -> [String]
    
    // 从路径加载图片
    static func loadImage(from path: String) -> StoredPlatformImage?
}
```

### 7.6 HarmonyOS — DataManager

```typescript
class DataManagerClass {
    travels: Travel[] = []
    postcards: Postcard[] = []
    
    init()                              // 初始化，加载 Preferences 数据
    save()                              // 持久化到 Preferences
    
    // Travel 操作
    addTravel(travel: Travel)
    updateTravel(travel: Travel)
    deleteTravel(travel: Travel)        // 级联删除关联明信片
    setCurrentTravel(travel: Travel)
    endTravel(travel: Travel)
    
    // Postcard 操作
    addPostcard(postcard: Postcard)
    updatePostcard(postcard: Postcard)
    deletePostcard(postcard: Postcard)
    toggleFavorite(postcard: Postcard)
    
    // 查询
    get currentTravel(): Travel | undefined
    get otherTravels(): Travel[]
    get sortedPostcards(): Postcard[]
    get uniqueCityCount(): number
    computeUserStats(): UserStats
}

export const DataManager = new DataManagerClass()   // 全局单例
```

### 7.7 RecordFlowView (iOS) — 记录流程

```swift
struct RecordFlowView: View {
    // 4 步记录流程
    enum RecordStep {
        case chooseMethod   // 选择记录方式 (拍照/语音/文字/相册)
        case capture        // 相机拍摄 / 相册选择
        case edit           // 编辑 (地点/备注/标签)
        case preview        // 明信片预览 & 保存
    }
    
    // 核心方法
    func savePostcard()                         // 保存明信片到 SwiftData
    func requestLocationAutofill(force:)        // 自动获取当前位置
    func importSelectedPhotos(from:) async      // 导入相册照片
}
```

---

## 8. 设计系统

### 8.1 品牌色系统

| 颜色 | Hex | 用途 |
|:---|:---|:---|
| stampRed | `#B84A38` | 邮票红，强调色、按钮、邮戳 |
| travelBlue | `#0F5D49` | 旅行绿，主色调、标题、导航 |
| paperBeige | `#F4EFE2` | 纸张米色，卡片背景 |
| inkBlack | `#1D2A25` | 墨黑色，正文文字 |
| pencilGray | `#6A675B` | 铅笔灰，次要文字 |
| stampGray | `#A49D8B` | 邮票灰，辅助文字 |
| dawnYellow | `#D8BF7D` | 晨曦黄，装饰色 |
| pageBackground | `#FAF7EF` | 页面背景色 |

### 8.2 核心视觉组件

| 组件 | 说明 |
|:---|:---|
| `PostalTextureBackground` | 全局背景纹理 (噪点 + 渐变 + 水印) |
| `PostalTicket` | 邮票卡片容器 (圆角 + 边框 + 齿孔效果) |
| `PostalStampSeal` | 邮戳印章 (圆形边框 + 旋转文字) |
| `PostalWaveLine` | 波浪线装饰 (Canvas 绘制) |
| `PostalStatsTicket` | 统计票据 (图标 + 数值 + 分隔线) |
| `PostalEmptyState` | 空状态组件 (图标 + 标题 + 描述 + 操作按钮) |
| `StampPerforationOverlay` | 邮票齿孔遮罩效果 |

---

## 9. 依赖关系

### 9.1 iOS 依赖

```swift
// Package.swift
platforms: [.iOS(.v17), .macOS(.v14)]

// 系统框架 (无需额外依赖)
import SwiftUI      // UI 框架
import SwiftData    // 数据持久化
import Combine      // 异步编程
import MapKit       // 地图
import CoreLocation // 定位
import AVFoundation // 相机
import PhotosUI     // 相册选择
import Security     // Keychain

// 预留第三方 SDK (注释状态)
// 阿里云 OSS SDK
// 高德地图 SDK
// 微信 OpenSDK
```

### 9.2 HarmonyOS 依赖

```typescript
// 系统模块
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import router from '@ohos.router'
```

### 9.3 模块依赖图

```
ContentView (App 根视图)
├── HomeView
│   ├── PostcardsApp (SwiftData 容器)
│   ├── Travel (Model)
│   ├── Postcard (Model)
│   ├── PostalVisualSystem (DesignSystem)
│   └── FABButton (DesignSystem)
├── TimelineView
│   ├── PostcardCard
│   └── TravelFilterChips
├── MapView
│   └── MapKit
├── CollectionView
├── ProfileView
└── RecordFlowView (Sheet 弹出)
    ├── CameraService
    ├── LocationManager
    └── LocalMediaStore

APIClient
├── KeychainService
└── Endpoint

LocationManager
└── CoreLocation

CameraService
└── AVFoundation
```

---

## 10. 项目运行方式

### 10.1 iOS 客户端

**环境要求:**
- macOS 14+
- Xcode 15.0+
- iOS 17.0+ Simulator 或真机

**运行方式一：Xcode (推荐)**
```bash
cd Postcards-iOS
open Package.swift
# 或直接用 Xcode 打开 Postcards-iOS 目录
```

**运行方式二：命令行构建**
```bash
cd Postcards-iOS
xcodebuild -scheme Postcards -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### 10.2 HarmonyOS 客户端

**环境要求:**
- DevEco Studio 4.0+
- HarmonyOS SDK API 9+

**运行方式:**
```bash
# 使用 DevEco Studio 打开 Postcards-Harmony 目录
# 连接鸿蒙模拟器或真机，点击运行
```

---

## 11. 文档与规范

### 11.1 项目文档清单

| 文档 | 路径 | 说明 |
|:---|:---|:---|
| 产品需求文档 | `Postcards_PRD_v2.md` | 用户故事、功能列表、验收标准 |
| 技术架构设计 | `Postcards_技术架构设计.md` | 整体架构、技术选型、服务设计 |
| 架构任务分解 | `Postcards_架构任务分解_v1.md` | MVP 任务拆分、工时估算 |
| 设计规范 | `Postcards_设计规范与设计语言.md` | UI 设计规范、视觉语言 |
| 产品原型 | `Postcards_产品原型设计.md` | 交互原型 |
| QA 测试策略 | `Postcards_QA测试策略.md` | 测试计划 |
| 工程师评审 | `Postcards_工程师评审意见.md` | 技术评审记录 |
| LandingPage 文案 | `Postcards_LandingPage文案.md` | 产品文案 |

### 11.2 代码规范

- **命名**: Swift 使用 camelCase，类型名大写开头；ArkTS 使用 camelCase
- **注释**: 关键逻辑添加注释，避免无意义注释
- **结构**: 按功能模块分层 (App/Core/DesignSystem/Features)
- **状态管理**: SwiftUI 使用 `@State`/`@StateObject`，ArkTS 使用 `@State`/`@Link`
- **错误处理**: Combine 使用 `sink(receiveCompletion:receiveValue:)`，Swift 使用 `do-catch`

---

## 附录：MVP 功能清单

| 模块 | 功能 | 状态 |
|:---|:---|:---:|
| 用户系统 | 本地使用 (无登录) | ✅ |
| 记录功能 | 拍照记录 | ✅ |
| 记录功能 | 相册导入 | ✅ |
| 记录功能 | 自动地点识别 | ✅ |
| 记录功能 | 手动地点编辑 | ✅ |
| 时间轴 | 明信片瀑布流 | ✅ |
| 时间轴 | 按旅行筛选 | ✅ |
| 时间轴 | 按日期分组 | ✅ |
| 地图 | 足迹地图展示 | ✅ |
| 地图 | 城市邮戳标记 | ✅ |
| 旅行管理 | 创建/结束旅行 | ✅ |
| 旅行管理 | 历史旅行查看 | ✅ |
| 分享 | 生成分享卡片 (预留) | ⚠️ |
| 云同步 | 后端 API (预留) | ⚠️ |
| 第三方登录 | 微信/Apple (预留) | ⚠️ |

---

*本文档基于代码仓库当前状态生成，后续迭代请及时更新。*
