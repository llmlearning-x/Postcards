# Postcards - 系统架构设计 + 任务分解 (v1.0)

> **架构师**: 高见远 (gao)
> **日期**: 2026-05-08
> **依据文档**: `Postcards_PRD_v2.md` + `Postcards_技术架构设计.md` + `Postcards_工程师评审意见.md`
> **状态**: 待评审

---

## 一、架构设计决策

### 1.1 PRD 关键约束提取

| 约束项 | PRD 定义 | 架构影响 |
|:---|:---|:---|
| MVP 范围 | 用户注册、拍照记录、时间轴、地图足迹、基础分享 | 服务可合并部署，不必一步到位微服务 |
| AI 功能 MVP | 用规则筛选替代 ML 模型 | AI 服务 MVP 阶段轻量化，无需 GPU 资源 |
| 第三方登录 MVP | 微信/Apple 登录在 MVP 排除（仅手机号+验证码） | OAuth 集成可延后到 V1 |
| 离线模式 | MVP 先本地存储，云同步延后 | MVP 无需复杂同步策略 |
| 支付 MVP | 订阅/印刷延后到 V1+ | 支付服务 MVP 阶段不启动 |
| 目标平台 | iOS 14+ 优先，Android 10+ 后续 | MVP 阶段专注 iOS |
| 目标市场 | 中国市场为主 | 全栈阿里云生态，高德地图 |

### 1.2 MVP 简化策略

现有 `Postcards_技术架构设计.md` 定义了 8 个微服务（User/Travel/Media/AI/Map/Share/Payment/Notify）。**MVP 阶段不实施完整微服务拆分**，原因：

1. Payment 服务在 MVP 中不启用
2. Notify 服务 MVP 仅需短信验证码，可合并到 User 服务
3. Share 服务（生成分享卡片）可合并到 Travel 服务
4. AI 服务 MVP 仅做规则筛选，体量极小

**MVP 服务合并方案**：

```
MVP 阶段（3 个服务）:
├── api-gateway          # 阿里云 API 网关（托管）
├── user-service         # 用户 + 认证 + 验证码短信
└── travel-service       # 旅行 + 明信片 + 媒体处理 + 地图数据 + AI 规则筛选 + 分享卡片

V1 阶段拆分:
├── ai-service           # 从 travel-service 拆出（语音转文字、故事生成）
├── notify-service       # 从 user-service 拆出（推送、站内信）
└── payment-service      # 新增（订阅支付）
```

### 1.3 数据库简化

| 原方案 | MVP 简化 | 理由 |
|:---|:---|:---|
| PostgreSQL + MongoDB + Redis + ES + ClickHouse | PostgreSQL + Redis + OSS | MVP 无全文搜索需求（本地筛选即可）、无时序分析、明信片结构固定不需要 MongoDB |
| Elasticsearch 搜索引擎 | PostgreSQL LIKE + 索引 | MVP 用户量小，PostgreSQL 足够 |
| ClickHouse 分析数据库 | 不部署 | V1 再引入 |

### 1.4 iOS 客户端架构

现有 iOS 项目 (`Postcards-iOS/`) 已建立基本结构：

```
Postcards-iOS/
├── Postcards/
│   ├── App/              # PostcardsApp.swift, ContentView.swift
│   ├── Core/
│   │   ├── Network/      # APIClient.swift, KeychainService.swift
│   │   ├── Location/     # LocationManager.swift
│   │   ├── Media/        # CameraService.swift
│   │   └── Persistence/  # Models.swift, LocalMediaStore.swift, MockBackendSeeder.swift
│   ├── DesignSystem/
│   │   ├── Components/   # PostcardCard, FABButton, StampElements, etc.
│   │   └── Colors/       # PostcardColors.swift
│   └── Features/
│       ├── Home/         # HomeView, TravelDetailView
│       ├── Timeline/     # TimelineView
│       ├── Record/       # RecordFlowView
│       ├── Map/          # MapView
│       ├── Collection/   # CollectionView
│       └── Profile/      # ProfileView
```

**现有代码评估**：UI 壳子和 Mock 数据已就位，DesignSystem 组件齐全。核心缺失：
- 后端 API 集成（目前使用 MockBackendSeeder）
- 认证流程（登录/注册页面和逻辑）
- 真实数据持久化（SQLite/CoreData）
- 离线数据同步策略

---

## 二、MVP 技术架构（最终方案）

### 2.1 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                     客户端 (iOS 14+)                         │
│  SwiftUI + Combine + CoreLocation + AVFoundation + MapKit   │
│  本地持久化: SQLite (FMDB/GRDB)                              │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS (TLS 1.3)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              阿里云 API 网关 (托管)                           │
│  JWT 认证 · 限流 · 请求路由 · 日志                           │
└──────────┬──────────────────────────────┬───────────────────┘
           │                              │
           ▼                              ▼
┌──────────────────────┐    ┌──────────────────────────────────┐
│   User Service       │    │      Travel Service               │
│   (Go / Gin)         │    │      (Go / Gin)                   │
│                      │    │                                   │
│  - 注册/登录         │    │  - 旅行 CRUD                      │
│  - 短信验证码        │    │  - 明信片 CRUD                    │
│  - Token 管理        │    │  - 照片上传/处理                  │
│  - 个人资料          │    │  - 地点识别 (EXIF+高德逆地理)     │
│                      │    │  - 天气获取                       │
│                      │    │  - 标签系统                       │
│                      │    │  - 足迹统计 (Redis Geo)           │
│                      │    │  - 分享卡片生成                   │
│                      │    │  - 规则筛选 (替代 AI 精选)        │
└──────────┬───────────┘    └──────────────┬────────────────────┘
           │                               │
           ▼                               ▼
┌──────────────────────┐    ┌──────────────────────────────────┐
│  PostgreSQL (RDS)    │    │  PostgreSQL (同一实例)            │
│  - users             │    │  - travels, postcards, photos    │
│  - sessions          │    │  - tags, postcard_tags           │
└──────────────────────┘    └──────────────────────────────────┘
           │                               │
           ▼                               ▼
┌──────────────────────┐    ┌──────────────────────────────────┐
│  Redis (阿里云)      │    │  阿里云 OSS + CDN                 │
│  - 验证码缓存        │    │  - 照片原图/多尺寸                │
│  - Token 黑名单      │    │  - 分享卡片图片                   │
│  - 会话管理          │    │                                   │
│  - Geo 索引          │    │                                   │
└──────────────────────┘    └──────────────────────────────────┘
```

### 2.2 技术选型确认

| 层 | 选型 | 理由 |
|:---|:---|:---|
| **iOS 客户端** | SwiftUI + Combine | 已有代码基础，声明式 UI 效率高 |
| **iOS 本地存储** | SQLite (GRDB.swift) | 轻量、高性能、支持离线场景 |
| **后端语言** | Go (Gin 框架) | 高并发、编译快、部署简单 |
| **API 网关** | 阿里云 API 网关（托管） | 零运维、自动扩缩容、插件生态 |
| **数据库** | PostgreSQL 15 (阿里云 RDS) | ACID、复杂查询、PostGIS 扩展 |
| **缓存** | Redis 7 (阿里云 Redis) | 验证码、Geo 索引、会话管理 |
| **对象存储** | 阿里云 OSS + CDN | 国内低延迟、自动多尺寸图片处理 |
| **短信** | 阿里云短信 | 验证码发送 |
| **地图** | 高德地图 iOS SDK | 国内适配好、逆地理编码准确 |
| **CI/CD** | GitHub Actions + 阿里云容器服务 | 自动构建、部署 |
| **监控** | 阿里云 SLS + Prometheus | 日志 + 指标监控 |

### 2.3 数据模型（MVP 精简版）

```sql
-- ===== 用户服务 =====

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone           VARCHAR(20) UNIQUE NOT NULL,
    nickname        VARCHAR(50),
    avatar_url      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_settings (
    user_id         UUID PRIMARY KEY REFERENCES users(id),
    notification_enabled BOOLEAN DEFAULT TRUE,
    language        VARCHAR(10) DEFAULT 'zh-CN',
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ===== 旅行服务 =====

CREATE TABLE travels (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(100) NOT NULL,
    destination     VARCHAR(100),
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          VARCHAR(20) DEFAULT 'ONGOING',  -- ONGOING, COMPLETED
    cover_image_url TEXT,
    postcard_count  INT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE postcards (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    travel_id       UUID REFERENCES travels(id) ON DELETE SET NULL,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    location_name   VARCHAR(200),
    location_lat    DECIMAL(10, 8),
    location_lng    DECIMAL(11, 8),
    country         VARCHAR(100),
    city            VARCHAR(100),
    recorded_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    weather_condition VARCHAR(50),
    weather_temp    DECIMAL(4, 1),
    note            TEXT,
    is_favorite     BOOLEAN DEFAULT FALSE,
    sync_status     VARCHAR(20) DEFAULT 'SYNCED',  -- SYNCED, PENDING, FAILED
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE photos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    postcard_id     UUID NOT NULL REFERENCES postcards(id) ON DELETE CASCADE,
    original_url    TEXT NOT NULL,
    thumbnail_url   TEXT,
    medium_url      TEXT,
    width           INT,
    height          INT,
    file_size       BIGINT,
    exif_data       JSONB,
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(50) UNIQUE NOT NULL,
    usage_count     INT DEFAULT 0
);

CREATE TABLE postcard_tags (
    postcard_id     UUID REFERENCES postcards(id) ON DELETE CASCADE,
    tag_id          UUID REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (postcard_id, tag_id)
);

-- ===== iOS 本地 SQLite (GRDB) =====
-- 结构与 PostgreSQL 一致，额外增加 sync_status 字段用于离线同步
-- 本地优先写入，联网后批量同步到服务端

-- ===== 索引 =====
CREATE INDEX idx_postcards_user_id ON postcards(user_id);
CREATE INDEX idx_postcards_travel_id ON postcards(travel_id);
CREATE INDEX idx_postcards_recorded_at ON postcards(recorded_at DESC);
CREATE INDEX idx_postcards_is_favorite ON postcards(is_favorite) WHERE is_favorite = TRUE;
CREATE INDEX idx_photos_postcard_id ON photos(postcard_id);
CREATE INDEX idx_travels_user_id ON travels(user_id);
CREATE INDEX idx_travels_status ON travels(status);
CREATE INDEX idx_postcard_tags_tag_id ON postcard_tags(tag_id);
```

### 2.4 API 设计（MVP）

#### 认证模块

```
POST   /api/v1/auth/send-code        # 发送短信验证码
  Body: { phone: "13800138000" }
  Resp: { expires_in: 300 }

POST   /api/v1/auth/login            # 验证码登录（自动注册）
  Body: { phone: "13800138000", code: "123456" }
  Resp: { access_token, refresh_token, user }

POST   /api/v1/auth/refresh          # 刷新 Token
  Body: { refresh_token: "..." }
  Resp: { access_token, refresh_token }

POST   /api/v1/auth/logout           # 登出
  Headers: { Authorization: Bearer ... }
  Resp: { message: "ok" }
```

#### 用户模块

```
GET    /api/v1/users/me              # 获取当前用户
PUT    /api/v1/users/me              # 更新用户信息
  Body: { nickname, avatar_url }
GET    /api/v1/users/me/stats        # 用户统计
  Resp: { total_travels, total_postcards, total_cities, total_countries }
```

#### 旅行模块

```
POST   /api/v1/travels               # 创建旅行
  Body: { title, destination, start_date }
GET    /api/v1/travels               # 旅行列表
  Query: ?status=ONGOING&page=1&size=20
GET    /api/v1/travels/:id           # 旅行详情
PUT    /api/v1/travels/:id           # 更新旅行
POST   /api/v1/travels/:id/complete  # 结束旅行
DELETE /api/v1/travels/:id           # 删除旅行
```

#### 明信片模块

```
POST   /api/v1/postcards             # 创建明信片
  Body: { travel_id?, photos: [url...], location, recorded_at, note, tags[] }
GET    /api/v1/postcards             # 明信片列表
  Query: ?travel_id=...&tag=...&page=1&size=20&sort=recorded_at_desc
GET    /api/v1/postcards/:id         # 明信片详情
PUT    /api/v1/postcards/:id         # 更新明信片
DELETE /api/v1/postcards/:id         # 删除明信片
POST   /api/v1/postcards/:id/favorite # 收藏/取消
```

#### 媒体模块

```
POST   /api/v1/media/upload          # 上传文件
  Content-Type: multipart/form-data
  Resp: { id, urls: { original, medium, thumbnail }, width, height, exif }
```

#### 地图模块

```
GET    /api/v1/maps/footprint        # 用户足迹
  Resp: { cities: [{name, country, lat, lng, count}], total_cities, total_countries }

GET    /api/v1/maps/travels/:id/route # 旅行轨迹
  Resp: { points: [{lat, lng, recorded_at}], bounds }
```

#### 分享模块

```
POST   /api/v1/share/card            # 生成分享卡片
  Body: { postcard_id, style: "postcard|photo|story" }
  Resp: { image_url, download_url }
```

#### 同步模块（离线支持）

```
POST   /api/v1/sync                  # 批量同步离线数据
  Body: { postcards: [...], deleted_ids: [...] }
  Resp: { synced: [...], conflicts: [...] }
GET    /api/v1/sync/changes          # 获取服务端变更
  Query: ?since=2026-05-08T00:00:00Z
  Resp: { postcards: [...], travels: [...], deleted_ids: [...] }
```

---

## 三、技术风险与缓解措施

### 3.1 高风险项（采纳工程师评审意见）

| 风险 | 影响 | 缓解措施 |
|:---|:---|:---|
| **离线同步冲突** | 数据不一致、数据丢失 | MVP 采用"单设备离线 + 服务端权威"策略。客户端本地 SQLite 优先写入并标记 `PENDING`，联网后按 `created_at` 排序同步。冲突时以服务端时间为准，客户端弹窗提示。不实现多人协作同步。 |
| **照片上传失败** | 用户记录丢失 | 实现分片上传 + 断点续传。上传失败本地保留原图，后台静默重试（指数退避，最多 3 次）。所有操作先本地持久化再上传。 |
| **AI 服务延迟** | 生成超时影响体验 | MVP 不集成 AI 生成。照片精选使用规则（清晰度 > 阈值、无模糊、非重复），延迟 < 100ms。语音转文字和故事生成留到 V1。 |
| **高德地图 API 限制** | 逆地理编码失败 | 本地缓存已解析的坐标→地名映射。请求失败时降级为"经纬度 + 未知地点"，允许用户手动编辑。设置请求队列 + 速率限制（10 QPS）。 |
| **短信验证码安全** | 滥用、刷号 | 图形验证码前置（人机验证）、同手机号 60 秒冷却、日发送上限 10 次/号、IP 限流。 |

### 3.2 中风险项

| 风险 | 缓解措施 |
|:---|:---|
| App Store 审核被拒 | 提前准备隐私协议、数据使用说明。避免使用私有 API。遵循 Human Interface Guidelines。 |
| OSS 存储成本增长 | 原图压缩至 80% 质量、中等尺寸 1080p、缩略图 300px。设置生命周期规则，90 天未访问的冷数据转低频存储。 |
| 数据库性能瓶颈 | 读写分离预留（主从延迟 < 100ms）。分页查询默认 20 条。关键查询建立覆盖索引。 |

---

## 四、任务分解

### 4.1 后端任务（按依赖顺序排列）

#### Phase B1: 基础设施（2 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| B1.1 | Go 项目脚手架搭建（Monorepo，user-service + travel-service） | 可编译的空服务 | 无 |
| B1.2 | GitHub Actions CI 流水线（lint + test + build） | CI 通过 | B1.1 |
| B1.3 | 阿里云 RDS PostgreSQL 实例创建 + 数据库迁移脚本 | 数据库就绪 | B1.1 |
| B1.4 | 阿里云 Redis 实例创建 + 连接配置 | Redis 就绪 | B1.1 |
| B1.5 | 阿里云 OSS Bucket 创建 + CDN 配置 | 存储就绪 | B1.1 |

#### Phase B2: 用户服务（5 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| B2.1 | 用户表建表 + CRUD 仓储层 | User repository | B1.3 |
| B2.2 | 短信验证码发送（阿里云短信） | 发送验证码 API | B1.4, B1.5 |
| B2.3 | 验证码校验 + 自动注册/登录 | 登录 API | B2.1, B2.2 |
| B2.4 | JWT Access Token + Refresh Token 签发与校验 | 认证中间件 | B2.3 |
| B2.5 | 用户个人信息管理 API | 用户 CRUD API | B2.1, B2.4 |
| B2.6 | 用户统计数据 API（旅行数、明信片数等） | 统计 API | B2.1, B3.* |

#### Phase B3: 旅行 + 明信片服务（8 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| B3.1 | 旅行表 + 明信片表 + 照片表 + 标签表建表 + 仓储层 | 全部表和 Repository | B1.3 |
| B3.2 | 旅行 CRUD API | 旅行 API | B3.1, B2.4 |
| B3.3 | 明信片 CRUD API（含标签关联） | 明信片 API | B3.1, B3.2 |
| B3.4 | 照片上传 API（multipart → OSS → 多尺寸缩略图） | 上传 API | B1.5, B3.3 |
| B3.5 | EXIF 数据提取（GPS、时间、设备） | EXIF 解析工具 | B3.4 |
| B3.6 | 高德逆地理编码集成（坐标 → 地名） | 地点识别 | B3.5 |
| B3.7 | 天气数据获取（和风天气/阿里云天气 API） | 天气接口 | B3.3 |

#### Phase B4: 地图 + 分享服务（4 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| B4.1 | Redis Geo 索引：明信片创建/删除时更新 | Geo 写入 | B1.4, B3.3 |
| B4.2 | 足迹统计 API（按城市聚合、国家数统计） | 足迹 API | B4.1 |
| B4.3 | 旅行轨迹 API（按时间排序的坐标点集） | 轨迹 API | B3.3 |
| B4.4 | 分享卡片图片生成（服务端图片合成，或返回模板让客户端渲染） | 分享 API | B3.3 |

#### Phase B5: 同步 + 离线支持（3 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| B5.1 | 批量同步 API（接收客户端离线数据） | sync API | B3.3 |
| B5.2 | 变更查询 API（基于 updated_at 增量拉取） | changes API | B3.3 |
| B5.3 | 冲突解决逻辑（服务端权威，时间戳比对） | 冲突处理 | B5.1, B5.2 |

#### Phase B6: 集成与部署（3 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| B6.1 | 阿里云 API 网关配置（路由、认证、限流） | 网关就绪 | B2.*, B3.* |
| B6.2 | 阿里云容器服务部署（或 ECS + Docker Compose） | 服务上线 | B2.*, B3.*, B4.* |
| B6.3 | 监控告警接入（SLS + Prometheus） | 监控就绪 | B6.2 |
| B6.4 | 端到端集成测试（iOS 客户端 → API 网关 → 服务 → 数据库） | 全链路通过 | B6.1, B6.2, iOS 就绪 |

**后端合计: ~25 人天**

---

### 4.2 iOS 客户端任务（按依赖顺序排列）

#### Phase I1: 基础架构改造（5 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I1.1 | 引入 GRDB.swift 本地数据库（替换 MockBackendSeeder） | SQLite 持久化层 | 无 |
| I1.2 | 本地数据模型定义（与 PostgreSQL 表结构对齐，增加 sync_status） | Models 层 | I1.1 |
| I1.3 | 网络层改造（APIClient 接入真实 API，Token 管理，自动刷新） | 网络层 | 无 |
| I1.4 | 同步管理器（离线队列、自动重试、增量同步） | SyncManager | I1.1, I1.3 |
| I1.5 | 依赖注入 / 状态管理方案（基于 ObservableObject + EnvironmentObject） | App 状态架构 | I1.1, I1.3 |

#### Phase I2: 认证模块（3 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I2.1 | 登录页面（手机号 + 验证码输入） | 登录 UI | 无 |
| I2.2 | 认证服务（发送验证码、登录、Token 存储 Keychain） | AuthViewModel | I1.3, I2.1 |
| I2.3 | 首次使用引导流程（欢迎页 → 权限申请 → 空状态引导） | Onboarding | I2.2 |
| I2.4 | 自动登录 + Token 过期处理 | 会话管理 | I1.3, I2.2 |

#### Phase I3: 记录流程（6 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I3.1 | 相机服务增强（AVFoundation 拍照、相册多选、EXIF 提取） | CameraService | 无 |
| I3.2 | 地点自动识别（EXIF GPS → 高德逆地理编码 → 地名展示） | LocationManager 增强 | I3.1 |
| I3.3 | 离线地点识别（坐标缓存、手动选择降级） | 离线地点 | I3.2 |
| I3.4 | 天气获取（API 调用 + 本地缓存） | WeatherService | I1.3 |
| I3.5 | 明信片编辑页面（照片预览、地点编辑、时间编辑、备注、标签） | RecordEditView | I3.2, I3.4, I1.1 |
| I3.6 | 明信片预览 + 保存（邮戳盖章动画、撤回按钮） | PreviewView | I3.5 |
| I3.7 | 照片上传服务（分片上传 + 断点续传 + 后台重试） | UploadService | I1.3, I3.5 |

#### Phase I4: 旅行管理（3 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I4.1 | 创建旅行页面（目的地、开始日期选择） | CreateTravelView | I1.3 |
| I4.2 | 旅行列表页面（进行中 + 历史旅行） | TravelListView | I1.1, I1.3 |
| I4.3 | 首页改造（当前旅行卡片绑定真实数据、地图缩略图） | HomeView 改造 | I4.2, I5.1 |

#### Phase I5: 时间轴模块（4 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I5.1 | 瀑布流列表（LazyVGrid + 明信片卡片 + 日期分组） | TimelineView 改造 | I1.1 |
| I5.2 | 旅行筛选器（Chip 选择器 + 数据过滤） | TravelFilterChips 改造 | I5.1 |
| I5.3 | 明信片详情页（全屏浏览、左右滑动、信息展示） | PostcardDetailView | I5.1 |
| I5.4 | 下拉刷新 + 上拉加载更多（分页 + 增量同步） | 分页加载 | I5.1, I1.4 |

#### Phase I6: 地图模块（4 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I6.1 | 高德地图 SDK 集成（替换 MapKit，国内体验更佳） | AMap 集成 | 无 |
| I6.2 | 城市邮戳标记（自定义标注、点击展开明信片） | 邮戳标注 | I6.1, I1.1 |
| I6.3 | 足迹统计展示（底部统计栏：城市数/国家数） | 统计 UI | I6.2 |
| I6.4 | 旅行轨迹展示（单条旅行的连线 Polyline） | 轨迹展示 | I6.1, I1.3 |

#### Phase I7: 收藏 + 分享 + 个人中心（4 人天）

| # | 任务 | 产出 | 依赖 |
|:---:|:---|:---|:---:|
| I7.1 | 收藏功能（星标 + 收藏列表） | CollectionView 改造 | I1.1 |
| I7.2 | 分享功能（生成分享卡片图片 + 系统分享面板 + 保存相册） | ShareService | I3.6 |
| I7.3 | 个人中心页面改造（真实统计数据、设置页面） | ProfileView 改造 | I1.3, I2.2 |
| I7.4 | 标签功能（添加/删除标签、按标签筛选） | 标签 UI + 逻辑 | I3.5, I5.1 |

**iOS 客户端合计: ~29 人天**

---

### 4.3 总工时汇总

| 阶段 | 后端 | iOS | 合计 | 天数（并行） |
|:---|:---:|:---:|:---:|:---:|
| Phase 1: 基础设施 | B1 (2) | I1 (5) | 7 | 5 |
| Phase 2: 用户+认证 | B2 (5) | I2 (3) | 8 | 5 |
| Phase 3: 核心 (旅行+记录) | B3 (8) | I3+I4 (9) | 17 | 9 |
| Phase 4: 浏览 (时间轴+地图) | B4 (4) | I5+I6 (8) | 12 | 8 |
| Phase 5: 收尾 (分享+同步) | B5+B6 (6) | I7 (4) | 10 | 6 |
| **总计** | **25** | **29** | **54** | **~6 周** |

> 注：以上为纯开发时间，假设 1 后端 + 1 iOS 工程师并行工作。
> 建议增加 20% Buffer → 总计 ~65 人天，约 7-8 周交付。
> 不含 QA 测试时间（另估 2-3 周）。

---

## 五、实施里程碑

| 里程碑 | 日期 | 内容 | 验收标准 |
|:---|:---|:---|:---|
| **M1: 项目启动** | W1 | 环境搭建、CI/CD、数据库、OSS | 本地可编译运行、CI 绿色 |
| **M2: 认证完成** | W2-3 | 用户注册登录 + Token 管理 | 可通过 API 注册登录、Token 自动刷新 |
| **M3: 核心闭环** | W4-5 | 拍照记录 + 旅行管理 + 地点识别 | 拍照→识别地点→预览→保存 全流程可用 |
| **M4: 浏览完成** | W6-7 | 时间轴 + 地图足迹 + 收藏 | 明信片可浏览、地图可展示足迹 |
| **M5: MVP 功能完整** | W8 | 分享 + 标签 + 离线同步 | 所有 MVP 功能可用 |
| **M6: 集成测试** | W9-10 | 端到端测试 + Bug 修复 | 核心流程 0 Bug、性能达标 |
| **M7: 内测发布** | W11 | TestFlight 内测 | 100 名用户可使用 |
| **M8: 正式发布** | W12-13 | App Store 上架 | 通过审核、正式可用 |

---

## 六、V1 增量规划（供参考）

V1 阶段需在 MVP 基础上新增：

| 新增模块 | 预估人天 | 前置条件 |
|:---|:---:|:---|
| 语音记录 + AI 转文字 | 8 | 阿里云/讯飞语音服务接入 |
| AI 照片精选（规则升级为简单模型） | 6 | ML 模型训练 + 推理服务 |
| 年度收藏册 | 6 | AI 精选 + PDF 生成 |
| 微信/Apple 第三方登录 | 5 | 微信开放平台审核 |
| 云同步优化（多设备同步） | 5 | 冲突解决策略设计 |
| 订阅付费 + 支付服务 | 10 | 微信/支付宝商户申请 |
| 无水印分享 | 3 | 订阅系统就绪 |
| **V1 合计** | **~43** | |

---

## 七、与工程师评审意见的对齐

| 评审建议 | 采纳情况 | 说明 |
|:---|:---|:---|
| 8 微服务 + iOS 结构清晰 | 部分采纳 | MVP 合并为 2 服务降低复杂度，V1 再拆分 |
| 技术选型合适 | 完全采纳 | SwiftUI/Go/阿里云 |
| 增加技术风险缓解措施 | 完全采纳 | 第三章详细列出 5 项高风险 + 3 项中风险及缓解方案 |
| MVP 约 60 人天 | 调整为 54 人天 | 通过服务合并减少了基础设施开销 |
| V1 约 45 人天 | 调整为 43 人天 | 基本一致 |
| V1.5 约 50 人天 | 未展开 | 等 V1 完成后再细化 |
| 离线同步 MVP 简化 | 完全采纳 | 单设备离线 + 服务端权威 |
| AI 服务用规则替代 | 完全采纳 | MVP 不集成 LLM |
| 代码组织建议 | 完全采纳 | 后端 Go 目录结构 + iOS DDD 模块划分 |
| Code Review 标准 | 完全采纳 | PR 审查清单纳入 CI |
| Git 提交规范 | 完全采纳 | Conventional Commits |

---

*文档版本: v1.0*
*架构师: 高见远*
*状态: 待团队主理人 + 工程师评审*
*下一步: 工程师寇豆码代码实现评审 → QA 闫测试测试策略规划*
