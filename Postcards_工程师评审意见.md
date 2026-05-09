# Postcards - 工程师评审意见

**评审人**: 寇豆码 (kou) - 软件工程师
**评审日期**: 2026-05-08
**评审依据**: `Postcards_技术架构设计.md` (v1.0) + `Postcards_产品原型设计.md`

---

## 一、任务列表与可行性评估

基于架构设计文档，我将系统拆解为以下任务模块，并评估其可行性与复杂度。

### 1.1 后端服务任务分解

| 模块 | 任务项 | 复杂度 | 技术要求 | 风险等级 |
|:---|:---|:---:|:---|:---:|
| **公共基础设施** | 项目脚手架 + CI/CD 流水线 | 中 | DevOps/GitHub Actions | 低 |
| | API 网关配置 (Kong/阿里云) | 中 | API Gateway | 中 |
| | 统一认证服务 (JWT/OAuth) | 高 | 安全工程 | 高 |
| | 日志与监控组件集成 | 中 | 阿里云 SLS/Prometheus | 低 |
| **用户服务** | 用户注册/登录 API | 中 | REST API + 加密 | 中 |
| | 第三方登录 (微信/Apple) | 高 | OAuth 2.0 集成 | 中 |
| | 用户信息管理 API | 低 | CRUD | 低 |
| **旅行服务** | 旅行 CRUD API | 中 | REST + 业务逻辑 | 低 |
| | 明信片 CRUD API | 中 | REST + 文件关联 | 中 |
| | 标签系统 | 中 | Many-to-Many 关系 | 低 |
| **媒体服务** | 文件上传服务 | 高 | OSS/S3、异步处理 | 中 |
| | 图片处理 (缩略图/EXIF) | 高 | 图片处理库、队列 | 中 |
| | CDN 刷新机制 | 中 | 消息队列集成 | 低 |
| **AI 服务** | 地标识别集成 | 高 | 阿里云/百度 API | 中 |
| | 语音转文字集成 | 高 | 科大讯飞/阿里云 | 中 |
| | AI 故事生成 | 高 | LLM API 集成 | 中 |
| | 照片智能精选 | 极高 | ML 模型训练 | 高 |
| **地图服务** | 足迹统计 API | 中 | Redis Geo + PostgreSQL | 中 |
| | 旅行轨迹 API | 中 | PostGIS/Redis | 中 |
| | 附近推荐 API | 高 | 地理索引 + 推荐算法 | 中 |
| **支付服务** | 订单系统 | 高 | 微信/支付宝 SDK | 高 |
| | 支付回调处理 | 高 | 异步通知、幂等性 | 高 |
| **通知服务** | 推送服务集成 | 高 | 极光/APNs/厂商通道 | 中 |
| | 短信服务集成 | 中 | 阿里云短信 | 低 |
| | 站内信系统 | 低 | 消息存储与查询 | 低 |

### 1.2 iOS 客户端任务分解

| 模块 | 任务项 | 复杂度 | 技术要求 | 风险等级 |
|:---|:---|:---:|:---|:---:|
| **基础架构** | 项目初始化 (SwiftUI) | 低 | Xcode/SwiftUI | 低 |
| | 网络层封装 (URLSession/Combine) | 中 | 响应式编程 | 中 |
| | 本地存储 (UserDefaults/SQLite) | 中 | 数据持久化 | 低 |
| | 离线模式支持 | 高 | 冲突解决策略 | 高 |
| **认证模块** | 登录/注册界面 | 低 | SwiftUI 表单 | 低 |
| | 第三方登录 (微信/Apple) | 高 | SDK 集成 | 中 |
| | Token 管理与刷新 | 中 | Keychain | 中 |
| **首页模块** | 当前旅行卡片 | 低 | SwiftUI View | 低 |
| | 地图缩略图 | 中 | MapKit 集成 | 低 |
| | FAB 快速入口 | 低 | SwiftUI 动画 | 低 |
| **记录流程** | 相机/相册模块 | 高 | AVFoundation/Photos | 高 |
| | 地点自动识别 | 中 | CoreLocation + AI | 中 |
| | 时间/天气获取 | 中 | API 调用 | 低 |
| | 语音录制 | 中 | AVFoundation | 中 |
| | 明信片预览生成 | 高 | 模板引擎/Canvas | 中 |
| **时间轴模块** | 瀑布流列表 | 中 | LazyVGrid/自定义 | 中 |
| | 筛选与搜索 | 中 | Elasticsearch 查询 | 中 |
| | 明信片详情页 | 低 | SwiftUI 导航 | 低 |
| **地图模块** | 全球足迹热力图 | 高 | MapKit 自定义覆盖层 | 中 |
| | 旅行轨迹展示 | 中 | MapKit Polyline | 中 |
| | 3D 地球模式 | 极高 | SceneKit/MapKit | 高 |
| **收藏夹模块** | 年度收藏册展示 | 中 | SwiftUI 动画 | 中 |
| | AI 精选照片 | 高 | API 集成 + 本地缓存 | 中 |
| **分享模块** | 生成分享卡片 | 中 | 图片合成 | 中 |
| | 社交分享 SDK | 中 | 微信/系统分享 | 中 |
| **订阅模块** | 订阅墙界面 | 低 | SwiftUI | 低 |
| | 微信/支付宝支付 | 高 | SDK 集成 | 高 |

---

## 二、潜在技术难点与风险

### 2.1 高风险项 (需重点关注)

#### 1. AI 故事生成服务
- **难点**: 需要接入多个 LLM 提供商，Prompt 工程复杂，生成质量不稳定
- **风险**: 响应延迟可能影响用户体验，需要完善的错误处理和降级策略
- **建议**: 先实现简单版本，后续迭代优化 Prompt

#### 2. 照片智能精选
- **难点**: 需要训练自定义 CNN 模型，数据集标注工作量大
- **风险**: 模型效果可能不达预期，需要多轮迭代
- **建议**: MVP 阶段使用规则筛选，后续再引入 ML 模型

#### 3. 离线模式与数据同步
- **难点**: 冲突解决策略复杂，特别是多人协作场景
- **风险**: 数据一致性难以保证，可能出现数据丢失
- **建议**: MVP 阶段先实现单设备离线，协作功能延后

#### 4. 支付模块
- **难点**: 微信/支付宝 SDK 接入复杂，回调通知需高可靠性
- **风险**: 资金安全相关，测试覆盖率要求高
- **建议**: 沙箱环境充分测试，支付流程全链路日志

#### 5. 多平台一致性
- **难点**: iOS/Android/Web 三个平台同时开发，UI/UX 一致性挑战大
- **风险**: 各平台开发进度可能不一致
- **建议**: 先专注 iOS MVP，Android/Web 后续跟进

### 2.2 中风险项

| 风险项 | 描述 | 缓解措施 |
|:---|:---|:---|
| 图片上传失败 | 网络不稳定时大文件上传易失败 | 断点续传、分片上传 |
| 地图服务限制 | 高德/Google 地图 API 调用量限制 | 本地缓存、批量请求 |
| AI API 限流 | 通义千问/文心一言调用频率限制 | 请求队列、指数退避 |
| 敏感数据泄露 | 用户位置、照片等数据安全 | 传输加密、OSS 私有Bucket |
| 等保合规 | 等保三级测评流程复杂 | 提前规划，预留充足时间 |

### 2.3 低风险项

- 用户认证 (业界成熟方案)
- CRUD 业务逻辑 (架构清晰)
- 基础 UI 组件 (SwiftUI 生态完善)

---

## 三、代码组织建议

### 3.1 后端目录结构 (Go/NestJS)

```
postcards-backend/
├── cmd/
│   ├── api-gateway/          # API 网关入口
│   ├── user-service/         # 用户服务入口
│   ├── travel-service/       # 旅行服务入口
│   ├── media-service/        # 媒体服务入口
│   ├── ai-service/           # AI 服务入口
│   └── ...
├── internal/
│   ├── config/               # 配置管理
│   ├── middleware/           # 中间件 (认证、日志、限流)
│   ├── model/                # 数据模型 (DB models)
│   ├── repository/           # 数据访问层
│   ├── service/              # 业务逻辑层
│   ├── handler/              # HTTP/gRPC handlers
│   ├── dto/                  # Data Transfer Objects
│   └── utils/                # 工具函数
├── pkg/
│   ├── auth/                 # 认证相关 (JWT、OAuth)
│   ├── cache/                # Redis 封装
│   ├── storage/              # OSS/S3 封装
│   └── ai/                   # AI 提供商封装
├── proto/                    # gRPC proto 文件
├── migrations/               # 数据库迁移
├── scripts/                  # 运维脚本
├── tests/                    # 集成测试
├── Makefile
└── docker-compose.yml
```

### 3.2 iOS 目录结构 (SwiftUI)

```
Postcards-iOS/
├── App/
│   ├── PostcardsApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Network/              # 网络层
│   │   ├── APIClient.swift
│   │   ├── Endpoints.swift
│   │   └── NetworkError.swift
│   ├── Storage/              # 本地存储
│   │   ├── UserDefaultsManager.swift
│   │   ├── SQLiteManager.swift
│   │   └── KeychainManager.swift
│   ├── Location/             # 位置服务
│   └── Media/                # 媒体处理
├── Features/
│   ├── Auth/                 # 认证模块
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── Home/                 # 首页模块
│   ├── Record/               # 记录流程模块
│   ├── Timeline/             # 时间轴模块
│   ├── Map/                  # 地图模块
│   ├── Collection/           # 收藏夹模块
│   └── Profile/              # 个人中心模块
├── Shared/
│   ├── Components/           # 公共组件
│   ├── Extensions/           # 扩展
│   ├── Theme/               # 主题样式
│   └── Localizable/         # 国际化
├── Resources/
│   ├── Assets.xcassets/
│   └── Fonts/
├── Tests/
└── Postcards-iOS.xcodeproj
```

### 3.3 模块划分原则

1. **按业务领域划分模块** (DDD 风格)
   - 每个 Feature 模块包含完整的 Views/ViewModels/Models/Services

2. **Core 层独立于业务**
   - 网络、存储、位置等基础设施不依赖 Features

3. **Shared 层被所有模块共享**
   - UI 组件、扩展、工具函数统一管理

---

## 四、代码规范与最佳实践

### 4.1 命名规范

#### Swift 命名规范
```swift
// 类/结构体: UpperCamelCase
class PostcardService { }
struct TravelLocation { }

// 函数/变量: lowerCamelCase
func fetchPostcards() -> [Postcard] { }
var currentTravel: Travel?

// 常量: k + UpperCamelCase (可选)
// 枚举成员: UpperCamelCase
enum TravelStatus {
    case ongoing
    case completed
    case planned
}

// 文件命名: 与类型名一致
// PostcardService.swift
// travel-location.swift (低层级类型可用小写)
```

#### Go 命名规范
```go
// 包名: 小写、下划线分隔 (可选全小写)
package user_service
package travel_service

// 结构体: UpperCamelCase
type User struct {
    ID       uuid.UUID
    Nickname string
}

// 函数/变量: lowerCamelCase
func CreateUser(req *CreateUserRequest) (*User, error) { }

// 接口: UpperCamelCase，通常以 -er 结尾
type UserRepository interface { }

// 常量: UpperCamelCase 或全大写
const MaxPostcardCount = 100
```

### 4.2 Git 提交规范

#### Commit Message 格式
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

#### Type 类型
| Type | 说明 |
|:---|:---|
| feat | 新功能 |
| fix | Bug 修复 |
| docs | 文档更新 |
| style | 代码格式 (不影响功能) |
| refactor | 重构 (非新功能非修复) |
| perf | 性能优化 |
| test | 测试相关 |
| chore | 构建/工具变更 |

#### 示例
```
feat(auth): 添加微信一键登录功能

实现微信 OAuth 2.0 回调处理
- 授权页面跳转
- Access Token 换取
- 用户信息获取

Closes #123
```

```
fix(postcard): 修复上传大图时内存溢出的问题

使用渐进式加载替代一次性加载
设置图片最大分辨率限制

Fixes #456
```

### 4.3 Code Review 标准

#### 必须检查项
1. **功能正确性**: 代码是否实现了需求？
2. **边界情况**: 错误处理是否完善？空指针/空数组？
3. **安全性**: 是否有 SQL 注入/XSS/敏感信息泄露风险？
4. **性能**: 是否有 N+1 查询？大循环？内存泄漏？
5. **可测试性**: 关键逻辑是否有单元测试？

#### PR 审查清单
- [ ] 代码符合命名规范
- [ ] 有必要的注释 (复杂逻辑)
- [ ] 提交信息清晰
- [ ] 包含相关测试
- [ ] 没有不必要的依赖
- [ ] 变更范围最小化

### 4.4 API 设计规范

#### RESTful 风格
```
GET     /api/v1/travels           # 获取旅行列表
POST    /api/v1/travels           # 创建旅行
GET     /api/v1/travels/{id}      # 获取旅行详情
PUT     /api/v1/travels/{id}      # 更新旅行
DELETE  /api/v1/travels/{id}      # 删除旅行
```

#### 响应格式
```json
{
    "code": 0,
    "message": "success",
    "data": {
        // 业务数据
    },
    "timestamp": 1746748800
}
```

#### 错误响应
```json
{
    "code": 40001,
    "message": "旅行不存在",
    "details": {
        "travel_id": "abc123"
    }
}
```

### 4.5 数据库规范

#### PostgreSQL
- 表名: snake_case, 复数形式 (`travels`, `postcards`)
- 字段名: snake_case (`created_at`, `user_id`)
- 主键: `id` UUID 类型
- 时间戳: `created_at`, `updated_at` TIMESTAMPTZ
- 索引: 必要的查询字段建立索引
- 软删除: 使用 `deleted_at` 字段

#### Redis
- Key 命名: `:`,`:`,`:...` 格式
  - `postcards:user:123:travels` (用户的所有旅行)
  - `postcards:travel:456:postcards` (旅行的所有明信片)

---

## 五、开发工时估算

### 5.1 MVP 阶段 (核心功能闭环)

| 模块 | 任务 | 人天 | 说明 |
|:---|:---|:---:|:---|
| **基础设施** | 项目脚手架 + CI/CD | 3 | GitHub Actions + Docker |
| | API 网关配置 | 2 | Kong/阿里云 |
| | 统一认证服务 | 5 | JWT + OAuth 基础 |
| | 监控日志组件 | 2 | SLS + Prometheus |
| **用户服务** | 用户注册/登录 | 3 | + 短信验证码 |
| | 第三方登录 | 5 | 微信 + Apple |
| **旅行服务** | 旅行 CRUD | 3 | |
| | 明信片 CRUD | 4 | + 照片关联 |
| | 标签系统 | 2 | |
| **媒体服务** | 文件上传 | 5 | + 异步处理 |
| | 图片处理 | 5 | 缩略图 + EXIF |
| **地图服务** | 足迹统计 | 4 | Redis Geo |
| **iOS 基础** | 项目架构 | 3 | SwiftUI + Combine |
| | 网络层 | 3 | |
| | 本地存储 | 3 | |
| **iOS 功能** | 认证模块 | 4 | |
| | 首页 | 3 | |
| | 记录流程 | 8 | 相机 + 地点 + 预览 |
| | 时间轴 | 5 | |
| | 地图 | 5 | |
| | 收藏夹 | 4 | |
| **合计** | | **71** | ~3.5 人月 |

### 5.2 V1 阶段 (体验完善)

| 模块 | 任务 | 人天 | 说明 |
|:---|:---|:---:|:---|
| **AI 服务** | 地标识别 | 5 | |
| | 语音转文字 | 4 | |
| | AI 故事生成 | 8 | |
| **支付服务** | 订单系统 | 6 | |
| | 微信/支付宝 | 5 | |
| **通知服务** | 推送集成 | 5 | |
| | 短信服务 | 2 | |
| **iOS 增强** | 分享模块 | 4 | |
| | 订阅模块 | 3 | |
| | 离线模式 | 8 | |
| **后端优化** | 缓存优化 | 3 | |
| | 性能调优 | 5 | |
| **合计** | | **58** | ~3 人月 |

### 5.3 V1.5 阶段 (差异化功能)

| 模块 | 任务 | 人天 | 说明 |
|:---|:---|:---:|:---|
| **AI 增强** | 照片智能精选 | 15 | ML 模型 |
| **高级地图** | 3D 地球模式 | 10 | |
| | 旅行轨迹动画 | 5 | |
| **实体印刷** | 印刷订单系统 | 8 | |
| **多人协作** | 协作功能 | 12 | |
| **合计** | | **50** | ~2.5 人月 |

### 5.4 总工时汇总

| 阶段 | 后端 | iOS | 合计 |
|:---|:---:|:---:|:---:|
| MVP | 25 人天 | 35 人天 | 60 人天 |
| V1 | 25 人天 | 20 人天 | 45 人天 |
| V1.5 | 30 人天 | 20 人天 | 50 人天 |
| **总计** | **80 人天** | **75 人天** | **155 人天** |

> 注: 以上为纯开发时间估算，不包含:
> - 需求讨论、设计评审、Code Review 时间
> - 测试 (QA) 时间
> - 等保合规、备案等法务时间
> 建议在估算基础上增加 20-30% Buffer

---

## 六、建议与优先级

### 6.1 实施建议

1. **分阶段交付**: MVP → V1 → V1.5，避免 Scope Creep
2. **技术验证**: AI 功能上线前先做 PoC，验证效果
3. **移动优先**: iOS MVP 先行，Android/Web 复用 iOS 经验
4. **监控先行**: 上线前完善监控告警，快速定位问题
5. **自动化测试**: 支付等核心流程必须有自动化测试

### 6.2 团队配置建议

| 阶段 | 后端 | iOS | 其他 |
|:---|:---:|:---:|:---|
| MVP | 1-2 人 | 1-2 人 | 1 设计师 |
| V1 | 2 人 | 2 人 | |
| V1.5 | 2 人 | 1-2 人 | ML 工程师 (可选) |

---

*文档版本: v1.0*
*评审人: 寇豆码*
