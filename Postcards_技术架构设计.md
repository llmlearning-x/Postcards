# Postcards - 技术架构设计文档

## 一、架构总览

```
┌─────────────────────────────────────────────────────────────┐
│                        客户端层 (Client)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  iOS App    │  │ Android App │  │  Web (H5/小程序)     │  │
│  │  (SwiftUI)  │  │ (Jetpack    │  │  (React/Vue)         │  │
│  │             │  │  Compose)   │  │  分享页/轻量浏览      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      API 网关层 (Gateway)                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  阿里云 API 网关 / Kong                                  │ │
│  │  - 统一认证 (JWT)                                       │ │
│  │  - 限流熔断                                             │ │
│  │  - 请求路由                                             │ │
│  │  - 日志监控                                             │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     微服务层 (Microservices)                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ User     │ │ Travel   │ │ Media    │ │ AI       │        │
│  │ Service  │ │ Service  │ │ Service  │ │ Service  │        │
│  │ 用户服务  │ │ 旅行服务  │ │ 媒体服务  │ │ AI服务    │        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ Map      │ │ Share    │ │ Payment  │ │ Notify   │        │
│  │ Service  │ │ Service  │ │ Service  │ │ Service  │        │
│  │ 地图服务  │ │ 分享服务  │ │ 支付服务  │ │ 通知服务  │        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      数据层 (Data Layer)                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ PostgreSQL│ │ MongoDB  │ │ Redis    │ │ Elasticsearch│    │
│  │ 关系数据  │ │ 文档数据  │ │ 缓存     │ │ 搜索引擎    │    │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │ 阿里云 OSS │ │ 阿里云 CDN │ │ ClickHouse│                 │
│  │ 对象存储  │ │ 静态加速  │ │ 分析数据库 │                    │
│  └──────────┘ └──────────┘ └──────────┘                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    基础设施层 (Infrastructure)                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ Kubernetes│ │ Prometheus│ │ ELK Stack│ │ CI/CD    │      │
│  │ 容器编排   │ │ 监控告警   │ │ 日志系统  │ │ 自动化部署 │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 二、技术选型

### 2.1 客户端

| 平台 | 技术栈 | 理由 |
|:---|:---|:---|
| iOS | SwiftUI + Combine | 原生体验、声明式UI、国内 Apple 生态成熟 |
| Android | Jetpack Compose + Kotlin Coroutines | 与 iOS 对齐的声明式方案、国内 Kotlin 普及率高 |
| 跨平台方案 | Flutter / React Native | **不推荐**。本项目高度依赖相机、地图、国内 SDK 集成，原生方案体验最优、风险最低 |
| Web (分享页) | Next.js / Nuxt.js | SEO 友好、快速首屏 |

### 2.2 后端服务

| 组件 | 技术选型 | 理由 |
|:---|:---|:---|
| 主框架 | Go (Gin/Echo) 或 Node.js (NestJS) | 高并发、快速开发、国内人才储备足 |
| API 网关 | 阿里云 API 网关 / Kong | 云原生、插件丰富、国内低延迟 |
| 服务通信 | gRPC + Protocol Buffers / HTTP/JSON | 高性能内部通信、国内云厂商支持好 |
| 消息队列 | 阿里云 RocketMQ / 阿里云 Kafka | 异步处理、削峰填谷 |

### 2.3 数据存储

| 用途 | 数据库 | 选型理由 |
|:---|:---|:---|
| 用户/旅行关系数据 | PostgreSQL | ACID 事务、复杂查询 |
| 明信片内容/日志 | MongoDB | 灵活 Schema、富媒体存储 |
| 缓存/会话 | Redis Cluster | 高性能、支持地理索引 |
| 搜索 | Elasticsearch | 全文搜索、地理位置搜索 |
| 时序/分析数据 | ClickHouse | 高效聚合分析 |
| 文件存储 | 阿里云 OSS | 国内访问快、CDN 自动刷新 |

### 2.4 AI 与算法

| 功能 | 技术方案 |
|:---|:---|
| 地标识别 | 阿里云视觉智能 / 百度 AI 图像识别 |
| 语音转文字 | 科大讯飞语音听写 / 阿里云智能语音 |
| AI 故事生成 | 通义千问 / 文心一言 / 智谱 GLM / Kimi / DeepSeek |
| 照片智能精选 | 自定义 CNN 模型 + 美学评分 |
| 地理编码 | 高德地图 API / 百度地图 API |

---

## 三、核心服务设计

### 3.1 用户服务 (User Service)

```go
// 核心实体
User {
    id          UUID
    email       string
    phone       string
    nickname    string
    avatar_url  string
    created_at  timestamp
    subscription_type  enum(FREE, PRO)
}

// API 接口
POST   /api/v1/auth/register      // 注册
POST   /api/v1/auth/login         // 登录
POST   /api/v1/auth/oauth/{provider}  // 第三方登录
GET    /api/v1/users/me           // 获取当前用户
PUT    /api/v1/users/me           // 更新用户信息
GET    /api/v1/users/me/stats     // 旅行统计
```

### 3.2 旅行服务 (Travel Service)

```go
// 核心实体
Travel {
    id            UUID
    user_id       UUID
    title         string
    destination   string
    start_date    date
    end_date      date (nullable)
    status        enum(ONGOING, COMPLETED, PLANNED)
    cover_image   string
    created_at    timestamp
}

Postcard {
    id            UUID
    travel_id     UUID
    user_id       UUID
    photos        []Photo
    location      {
        lat       float64
        lng       float64
        name      string
        country   string
        city      string
    }
    recorded_at   timestamp
    weather       {
        condition string
        temp      float64
    }
    note          string (nullable)
    tags          []string
    is_favorite   bool
}

// API 接口
POST   /api/v1/travels              // 创建旅行
GET    /api/v1/travels               // 获取旅行列表
GET    /api/v1/travels/{id}          // 获取旅行详情
PUT    /api/v1/travels/{id}          // 更新旅行
DELETE /api/v1/travels/{id}          // 删除旅行
POST   /api/v1/travels/{id}/complete // 结束旅行

POST   /api/v1/postcards            // 创建明信片
GET    /api/v1/postcards            // 获取明信片列表
GET    /api/v1/postcards/{id}       // 获取明信片详情
PUT    /api/v1/postcards/{id}       // 更新明信片
DELETE /api/v1/postcards/{id}       // 删除明信片
POST   /api/v1/postcards/{id}/favorite // 收藏/取消收藏
```

### 3.3 媒体服务 (Media Service)

```go
// 处理流程
1. 接收上传文件 (multipart/form-data)
2. 病毒扫描 + 格式校验
3. 生成多尺寸缩略图 (原图/2K/1080p/缩略图)
4. 上传至 OSS + CDN 刷新
5. 提取 EXIF (GPS、时间、设备信息)
6. 返回媒体 URL 和元数据

// API 接口
POST   /api/v1/media/upload        // 上传文件
GET    /api/v1/media/{id}          // 获取媒体信息
DELETE /api/v1/media/{id}          // 删除媒体

// 图片处理参数
?w=800&h=600&fit=crop&q=80         // 尺寸裁剪 + 质量压缩
?blur=20                           // 模糊预览
```

### 3.4 AI 服务 (AI Service)

```go
// 地标识别
POST /api/v1/ai/landmark-recognize
Request:  { image_url: string }
Response: { landmark: string, confidence: float, lat: float, lng: float }

// 语音转文字
POST /api/v1/ai/speech-to-text
Request:  { audio_file: multipart }
Response: { text: string, confidence: float, duration: int }

// AI 故事生成
POST /api/v1/ai/generate-story
Request:  { 
    travel_id: UUID,
    style: enum(CASUAL, POETIC, HUMOROUS),
    language: enum(ZH, EN, JA, ...)
}
Response: { title: string, content: string, suggested_photos: []UUID }

// 照片精选
POST /api/v1/ai/select-highlights
Request:  { travel_id: UUID, count: int (default 20) }
Response: { selected_postcards: []UUID, reason: []string }
```

### 3.5 地图服务 (Map Service)

```go
// 基于 Redis Geo 索引 + PostGIS

// API 接口
GET /api/v1/maps/footprint          // 获取用户足迹数据
Response: {
    countries: [{ code, name, count, first_visit, last_visit }],
    cities: [{ name, country, lat, lng, count, postcards: [] }],
    total_countries: int,
    total_cities: int
}

GET /api/v1/maps/travel/{id}/route  // 获取旅行轨迹
Response: {
    points: [{ lat, lng, timestamp, postcard_id }],
    bounds: { ne: {lat, lng}, sw: {lat, lng} }
}

GET /api/v1/maps/nearby             // 附近推荐
Request:  { lat, lng, radius: int (km) }
Response: [{ place_id, name, type, distance, photo_url }]
```

### 3.6 支付服务 (Payment Service)

```go
// 核心实体
Order {
    id            UUID
    user_id       UUID
    order_type    enum(SUBSCRIPTION_MONTHLY, SUBSCRIPTION_YEARLY, PRINT_ALBUM)
    amount        int              // 单位：分
    currency      string           // CNY
    status        enum(PENDING, PAID, CANCELLED, REFUNDED)
    created_at    timestamp
    paid_at       timestamp (nullable)
}

// API 接口
POST /api/v1/payments/create        // 创建订单
Request:  { order_type: string, coupon_code: string (nullable) }
Response: { order_id: UUID, amount: int, pay_params: object }

POST /api/v1/payments/notify        // 支付回调（微信/支付宝异步通知）
Request:  平台原始通知数据
Response: { status: string }

GET  /api/v1/payments/orders        // 查询订单列表
GET  /api/v1/payments/orders/{id}   // 查询订单详情

// 支付渠道
- 微信支付：APP 支付 + JSAPI（H5/小程序）
- 支付宝：APP 支付 + 手机网站支付
```

### 3.7 通知服务 (Notify Service)

```go
// 推送渠道
- APP 推送：极光推送（Android）+ APNs（iOS）+ 华为/小米/OPPO/vivo 厂商通道
- 短信：阿里云短信服务（验证码、营销）
- 站内信：APP 内消息中心
- 微信：服务号模板消息 / 小程序订阅消息

// API 接口
POST /api/v1/notifications/push     // 发送推送
Request:  {
    user_id: UUID,
    channel: enum(PUSH, SMS, IN_APP, WECHAT),
    title: string,
    body: string,
    data: object (跳转参数)
}

POST /api/v1/notifications/broadcast  // 批量推送（运营消息）
GET  /api/v1/notifications            // 获取用户消息列表
PUT  /api/v1/notifications/{id}/read  // 标记已读
```

---

## 四、数据模型

### 4.1 PostgreSQL 关系模型

```sql
-- 用户表
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE,
    phone           VARCHAR(20) UNIQUE,
    password_hash   VARCHAR(255),
    nickname        VARCHAR(50) NOT NULL,
    avatar_url      TEXT,
    subscription    VARCHAR(20) DEFAULT 'FREE',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 旅行表
CREATE TABLE travels (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(100) NOT NULL,
    destination     VARCHAR(100),
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          VARCHAR(20) DEFAULT 'ONGOING',
    cover_image     TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 明信片表
CREATE TABLE postcards (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    travel_id       UUID REFERENCES travels(id) ON DELETE CASCADE,
    user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
    location_name   VARCHAR(200),
    location_lat    DECIMAL(10, 8),
    location_lng    DECIMAL(11, 8),
    country         VARCHAR(100),
    city            VARCHAR(100),
    recorded_at     TIMESTAMPTZ NOT NULL,
    weather_condition VARCHAR(50),
    weather_temp    DECIMAL(4, 1),
    note            TEXT,
    is_favorite     BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 照片表
CREATE TABLE photos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    postcard_id     UUID REFERENCES postcards(id) ON DELETE CASCADE,
    original_url    TEXT NOT NULL,
    thumbnail_url   TEXT,
    medium_url      TEXT,
    large_url       TEXT,
    width           INT,
    height          INT,
    exif_data       JSONB,
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 标签表
CREATE TABLE tags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(50) UNIQUE NOT NULL,
    usage_count     INT DEFAULT 0
);

-- 明信片标签关联
CREATE TABLE postcard_tags (
    postcard_id     UUID REFERENCES postcards(id) ON DELETE CASCADE,
    tag_id          UUID REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (postcard_id, tag_id)
);

-- 索引优化
CREATE INDEX idx_postcards_user_id ON postcards(user_id);
CREATE INDEX idx_postcards_travel_id ON postcards(travel_id);
CREATE INDEX idx_postcards_recorded_at ON postcards(recorded_at);
CREATE INDEX idx_photos_postcard_id ON photos(postcard_id);
CREATE INDEX idx_travels_user_id ON travels(user_id);
```

### 4.2 MongoDB 文档模型 (日志/AI 生成内容)

```json
// AI 生成故事
{
    "_id": "story_uuid",
    "travel_id": "travel_uuid",
    "user_id": "user_uuid",
    "title": "东京七日：从繁华到宁静",
    "content": "第一天抵达成田机场...",
    "style": "poetic",
    "language": "zh",
    "included_postcards": ["pc_1", "pc_2"],
    "generated_at": "2026-05-01T12:00:00Z",
    "user_edited": false
}

// 年度收藏册
{
    "_id": "album_uuid",
    "user_id": "user_uuid",
    "year": 2026,
    "title": "2026 年度旅行收藏",
    "cover_postcard": "pc_uuid",
    "sections": [
        {
            "title": "春 · 樱花季",
            "postcards": ["pc_1", "pc_2", "pc_3"],
            "ai_summary": "3月的日本，樱花盛开..."
        }
    ],
    "stats": {
        "total_postcards": 36,
        "total_countries": 5,
        "total_cities": 12
    },
    "created_at": "2026-12-31T00:00:00Z"
}
```

---

## 五、安全设计

### 5.1 认证与授权

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   客户端     │────▶│  API 网关    │────▶│  Auth 服务   │
│             │     │  (Kong)     │     │  (JWT/OAuth) │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              ▼
                                        ┌─────────────┐
                                        │  Redis      │
                                        │  Token 黑名单 │
                                        └─────────────┘
```

- **JWT 认证**: Access Token (15分钟) + Refresh Token (7天)
- **OAuth 2.0**: 支持 微信/Apple ID/手机号一键登录
- **权限控制**: RBAC 模型，区分 FREE/PRO 用户权限

### 5.2 数据安全

| 措施 | 实现 |
|:---|:---|
| 传输加密 | 全站 HTTPS (TLS 1.3) |
| 存储加密 | 敏感字段 AES-256 加密 |
| 文件安全 | OSS 私有 Bucket + 签名 URL (15分钟有效期) |
| 隐私模式 | 端到端加密，密钥仅存本地 |
| 数据备份 | 跨区域自动备份，RPO < 1小时 |

---

## 六、国内合规要求

### 6.1 资质与备案

| 合规项 | 要求 | 实施方式 |
|:---|:---|:---|
| **ICP 备案** | 国内服务器域名必须备案 | 阿里云备案系统，APP 同步备案 |
| **等保三级** | 用户量达 10 万需通过等保测评 | 阿里云等保合规套餐 |
| **APP 备案** | 工信部 APP 备案要求 | 通过应用商店分发前完成 |
| **算法备案** | AI 生成内容服务需算法备案 | 深度合成服务算法备案 |

### 6.2 数据安全与隐私

| 合规项 | 要求 | 实施方式 |
|:---|:---|:---|
| **数据不出境** | 用户照片、位置等敏感数据存储于国内 | 阿里云 OSS 大陆地域 + RDS 大陆地域 |
| **个人信息保护法** | 最小必要原则，明示同意 | 隐私协议 + 权限动态申请 |
| **数据加密** | 敏感字段国密 SM4 加密 + 传输 TLS 1.3 | 阿里云 KMS 密钥管理服务 |
| **内容审核** | AI 生成内容和用户上传图片需审核 | 阿里云内容安全（绿网）+ 百度 AI 审核 |
| **未成年人保护** | 限制未成年人使用 AI 生成等功能 | 实名认证 + 年龄校验 |

### 6.3 日志与审计

- **操作日志留存**：不少于 6 个月，存储于阿里云 SLS
- **访问日志**：全链路日志关联用户 ID，支持溯源
- **审计报表**：定期生成等保要求的审计报告

---

## 七、性能与扩展

### 6.1 缓存策略

```
┌─────────────┐
│  客户端缓存  │  ← 图片本地缓存 (LRU, 500MB)
├─────────────┤
│  CDN 缓存   │  ← 静态资源 + 图片 (TTL 30天)
├─────────────┤
│  Redis 缓存 │  ← 热点数据 (用户足迹、旅行列表)
├─────────────┤
│  数据库     │  ← 持久化存储
└─────────────┘
```

### 6.2 关键性能指标 (SLA)

| 指标 | 目标 |
|:---|:---|
| API 响应时间 (P99) | < 200ms |
| 图片上传 | < 3s (单张 5MB) |
| 首屏加载 | < 1.5s |
| 离线可用 | 核心功能 100% 可用 |
| 服务可用性 | 99.9% |

### 6.3 扩展方案

```
阶段 1 (0-10万用户): 单实例 + 云数据库
阶段 2 (10-100万):   容器化 + 读写分离
阶段 3 (100万+):     微服务拆分 + 分片 + 多地域部署 (华东/华北/华南)
```

---

## 八、部署架构

```
┌─────────────────────────────────────────┐
│                 阿里云                    │
│  ┌─────────────────────────────────────┐  │
│  │  VPC                                │  │
│  │  ┌─────────┐  ┌─────────┐          │  │
│  │  │ 公网子网 │  │ 私网子网 │          │  │
│  │  │         │  │         │          │  │
│  │  │ - LB    │  │ - K8s   │          │  │
│  │  │ - CDN   │  │ - DB    │          │  │
│  │  │ - Bastion│ │ - Cache │          │  │
│  │  └─────────┘  └─────────┘          │  │
│  └─────────────────────────────────────┘  │
│                                           │
│  多可用区部署 (杭州/上海/北京等地域多AZ)    │
│  自动扩缩容 (HPA + Cluster Autoscaler)      │
└─────────────────────────────────────────┘
```

---

## 九、监控与运维

| 组件 | 工具 | 用途 |
|:---|:---|:---|
| 指标采集 | 阿里云 Prometheus + Grafana 托管版 | 服务性能、业务指标 |
| 日志收集 | 阿里云 SLS (日志服务) | 分布式日志查询、实时告警 |
| 链路追踪 | 阿里云 ARMS / SkyWalking | 请求全链路追踪 |
| 告警通知 | 钉钉 / 企业微信 / 飞书 | 异常实时告警 |
| APM | 阿里云 ARMS / 腾讯云 APM | 应用性能监控 |

---

*文档版本: v1.0*  
*更新日期: 2026-05-01*
