# 我的秘密空间 - 后端接口需求文档

## 概述
本文档基于移动端功能需求，定义后端API接口规范，用于支持私密日记和相册应用的数据管理。

## 接口基础信息

### 通用规范
- **协议**: HTTPS
- **请求格式**: JSON
- **响应格式**: JSON
- **字符编码**: UTF-8
- **认证方式**: Token (JWT)

### 通用响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1698000000000
}
```

### 状态码定义
| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未授权/Token无效 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 1. 用户认证模块

### 1.1 用户注册/设置密码
**接口**: `POST /api/v1/auth/register`

**功能**: 首次使用时设置6位数字密码

**请求参数**:
```json
{
  "password": "123456",
  "confirmPassword": "123456",
  "deviceId": "unique-device-id"
}
```

**响应数据**:
```json
{
  "userId": "user-uuid",
  "token": "jwt-token",
  "createdAt": 1698000000000
}
```

### 1.2 密码登录
**接口**: `POST /api/v1/auth/login`

**功能**: 使用6位数字密码登录

**请求参数**:
```json
{
  "password": "123456",
  "deviceId": "unique-device-id"
}
```

**响应数据**:
```json
{
  "userId": "user-uuid",
  "token": "jwt-token",
  "tokenExpireAt": 1698086400000,
  "biometricEnabled": true
}
```

### 1.3 刷新Token
**接口**: `POST /api/v1/auth/refresh`

**功能**: 刷新访问令牌

**请求头**:
```
Authorization: Bearer {token}
```

**响应数据**:
```json
{
  "token": "new-jwt-token",
  "tokenExpireAt": 1698086400000
}
```

### 1.4 修改密码
**接口**: `PUT /api/v1/auth/password`

**功能**: 修改登录密码

**请求参数**:
```json
{
  "oldPassword": "123456",
  "newPassword": "654321",
  "confirmPassword": "654321"
}
```

**响应数据**:
```json
{
  "success": true,
  "message": "密码修改成功"
}
```

### 1.5 生物识别设置
**接口**: `PUT /api/v1/auth/biometric`

**功能**: 开启/关闭指纹识别

**请求参数**:
```json
{
  "enabled": true,
  "deviceBiometricId": "device-biometric-hash"
}
```

**响应数据**:
```json
{
  "success": true,
  "biometricEnabled": true
}
```

---

## 2. 日记管理模块

### 2.1 创建日记
**接口**: `POST /api/v1/diaries`

**功能**: 创建新的日记条目

**请求参数**:
```json
{
  "title": "今天的心情",
  "content": "日记正文内容...",
  "mood": "happy",
  "tags": ["生活", "工作"],
  "createdDate": 1698000000000
}
```

**字段说明**:
- `mood`: 心情类型 (happy/sad/calm/excited/tired)
- `tags`: 标签数组，最多10个
- `createdDate`: 日记创建时间戳

**响应数据**:
```json
{
  "diaryId": "diary-uuid",
  "title": "今天的心情",
  "content": "日记正文内容...",
  "mood": "happy",
  "tags": ["生活", "工作"],
  "createdAt": 1698000000000,
  "updatedAt": 1698000000000
}
```

### 2.2 获取日记列表
**接口**: `GET /api/v1/diaries`

**功能**: 获取日记列表（支持分页、搜索、筛选）

**查询参数**:
```
page=1
pageSize=20
keyword=心情
mood=happy
tags=生活,工作
startDate=1698000000000
endDate=1698086400000
sortBy=createdAt
sortOrder=desc
```

**响应数据**:
```json
{
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "items": [
    {
      "diaryId": "diary-uuid",
      "title": "今天的心情",
      "content": "日记正文内容...",
      "contentPreview": "日记正文内容...",
      "mood": "happy",
      "tags": ["生活", "工作"],
      "createdAt": 1698000000000,
      "updatedAt": 1698000000000
    }
  ]
}
```

### 2.3 获取日记详情
**接口**: `GET /api/v1/diaries/{diaryId}`

**功能**: 获取指定日记的详细信息

**响应数据**:
```json
{
  "diaryId": "diary-uuid",
  "title": "今天的心情",
  "content": "日记正文内容...",
  "mood": "happy",
  "tags": ["生活", "工作"],
  "createdAt": 1698000000000,
  "updatedAt": 1698000000000
}
```

### 2.4 更新日记
**接口**: `PUT /api/v1/diaries/{diaryId}`

**功能**: 更新日记内容

**请求参数**:
```json
{
  "title": "更新后的标题",
  "content": "更新后的内容...",
  "mood": "calm",
  "tags": ["生活"]
}
```

**响应数据**:
```json
{
  "diaryId": "diary-uuid",
  "title": "更新后的标题",
  "content": "更新后的内容...",
  "mood": "calm",
  "tags": ["生活"],
  "createdAt": 1698000000000,
  "updatedAt": 1698000100000
}
```

### 2.5 删除日记
**接口**: `DELETE /api/v1/diaries/{diaryId}`

**功能**: 删除指定日记

**响应数据**:
```json
{
  "success": true,
  "message": "日记删除成功"
}
```

### 2.6 批量删除日记
**接口**: `DELETE /api/v1/diaries/batch`

**功能**: 批量删除日记

**请求参数**:
```json
{
  "diaryIds": ["diary-uuid-1", "diary-uuid-2"]
}
```

**响应数据**:
```json
{
  "success": true,
  "deletedCount": 2,
  "message": "批量删除成功"
}
```

### 2.7 获取所有标签
**接口**: `GET /api/v1/diaries/tags`

**功能**: 获取用户使用过的所有标签

**响应数据**:
```json
{
  "tags": [
    {
      "name": "生活",
      "count": 25
    },
    {
      "name": "工作",
      "count": 18
    }
  ]
}
```

### 2.8 获取心情统计
**接口**: `GET /api/v1/diaries/mood-stats`

**功能**: 获取心情分布统计

**查询参数**:
```
startDate=1698000000000
endDate=1698086400000
```

**响应数据**:
```json
{
  "stats": [
    {
      "mood": "happy",
      "count": 30,
      "percentage": 40.0
    },
    {
      "mood": "calm",
      "count": 25,
      "percentage": 33.3
    }
  ],
  "totalDiaries": 75
}
```

---

## 3. 照片管理模块

### 3.1 上传照片
**接口**: `POST /api/v1/photos`

**功能**: 上传照片到相册

**请求格式**: `multipart/form-data`

**请求参数**:
```
file: [图片文件]
description: "照片描述"
takenAt: 1698000000000
```

**响应数据**:
```json
{
  "photoId": "photo-uuid",
  "url": "https://cdn.example.com/photos/xxx.jpg",
  "thumbnailUrl": "https://cdn.example.com/photos/xxx_thumb.jpg",
  "description": "照片描述",
  "fileSize": 1024000,
  "width": 1920,
  "height": 1080,
  "format": "jpg",
  "takenAt": 1698000000000,
  "uploadedAt": 1698000000000
}
```

### 3.2 批量上传照片
**接口**: `POST /api/v1/photos/batch`

**功能**: 批量上传多张照片

**请求格式**: `multipart/form-data`

**请求参数**:
```
files[]: [图片文件数组]
```

**响应数据**:
```json
{
  "totalCount": 5,
  "successCount": 5,
  "failedCount": 0,
  "photos": [
    {
      "photoId": "photo-uuid-1",
      "url": "https://cdn.example.com/photos/xxx1.jpg",
      "thumbnailUrl": "https://cdn.example.com/photos/xxx1_thumb.jpg"
    }
  ]
}
```

### 3.3 获取照片列表
**接口**: `GET /api/v1/photos`

**功能**: 获取照片列表（支持分页）

**查询参数**:
```
page=1
pageSize=30
startDate=1698000000000
endDate=1698086400000
sortBy=takenAt
sortOrder=desc
```

**响应数据**:
```json
{
  "total": 150,
  "page": 1,
  "pageSize": 30,
  "items": [
    {
      "photoId": "photo-uuid",
      "url": "https://cdn.example.com/photos/xxx.jpg",
      "thumbnailUrl": "https://cdn.example.com/photos/xxx_thumb.jpg",
      "description": "照片描述",
      "fileSize": 1024000,
      "width": 1920,
      "height": 1080,
      "format": "jpg",
      "takenAt": 1698000000000,
      "uploadedAt": 1698000000000
    }
  ]
}
```

### 3.4 获取照片详情
**接口**: `GET /api/v1/photos/{photoId}`

**功能**: 获取指定照片的详细信息

**响应数据**:
```json
{
  "photoId": "photo-uuid",
  "url": "https://cdn.example.com/photos/xxx.jpg",
  "thumbnailUrl": "https://cdn.example.com/photos/xxx_thumb.jpg",
  "description": "照片描述",
  "fileSize": 1024000,
  "width": 1920,
  "height": 1080,
  "format": "jpg",
  "exif": {
    "camera": "iPhone 14 Pro",
    "iso": "100",
    "aperture": "f/1.8"
  },
  "takenAt": 1698000000000,
  "uploadedAt": 1698000000000
}
```

### 3.5 更新照片信息
**接口**: `PUT /api/v1/photos/{photoId}`

**功能**: 更新照片描述等信息

**请求参数**:
```json
{
  "description": "更新后的照片描述"
}
```

**响应数据**:
```json
{
  "photoId": "photo-uuid",
  "description": "更新后的照片描述",
  "updatedAt": 1698000100000
}
```

### 3.6 删除照片
**接口**: `DELETE /api/v1/photos/{photoId}`

**功能**: 删除指定照片

**响应数据**:
```json
{
  "success": true,
  "message": "照片删除成功"
}
```

### 3.7 批量删除照片
**接口**: `DELETE /api/v1/photos/batch`

**功能**: 批量删除照片

**请求参数**:
```json
{
  "photoIds": ["photo-uuid-1", "photo-uuid-2"]
}
```

**响应数据**:
```json
{
  "success": true,
  "deletedCount": 2,
  "message": "批量删除成功"
}
```

### 3.8 获取照片统计
**接口**: `GET /api/v1/photos/stats`

**功能**: 获取照片统计信息

**响应数据**:
```json
{
  "totalPhotos": 150,
  "totalSize": 153600000,
  "formatsDistribution": {
    "jpg": 120,
    "png": 30
  },
  "uploadTrend": [
    {
      "date": "2024-10",
      "count": 25
    }
  ]
}
```

---

## 4. 用户设置模块

### 4.1 获取用户设置
**接口**: `GET /api/v1/settings`

**功能**: 获取用户的所有设置信息

**响应数据**:
```json
{
  "userId": "user-uuid",
  "biometricEnabled": true,
  "theme": "auto",
  "language": "zh-CN",
  "autoBackup": false,
  "backupFrequency": "daily",
  "notifications": {
    "enabled": true,
    "reminderTime": "20:00"
  },
  "privacy": {
    "dataEncryption": true,
    "hidePreviewInTaskSwitcher": true
  }
}
```

### 4.2 更新用户设置
**接口**: `PUT /api/v1/settings`

**功能**: 更新用户设置

**请求参数**:
```json
{
  "theme": "dark",
  "autoBackup": true,
  "notifications": {
    "enabled": true,
    "reminderTime": "21:00"
  }
}
```

**响应数据**:
```json
{
  "success": true,
  "message": "设置更新成功"
}
```

### 4.3 获取应用信息
**接口**: `GET /api/v1/about`

**功能**: 获取应用版本等信息

**响应数据**:
```json
{
  "appName": "我的秘密空间",
  "version": "1.0.0",
  "buildNumber": "100",
  "apiVersion": "v1",
  "minSupportedVersion": "1.0.0"
}
```

---

## 5. 数据备份与同步模块（可选）

### 5.1 创建备份
**接口**: `POST /api/v1/backup`

**功能**: 创建数据备份

**响应数据**:
```json
{
  "backupId": "backup-uuid",
  "backupTime": 1698000000000,
  "fileSize": 10240000,
  "downloadUrl": "https://cdn.example.com/backups/xxx.zip",
  "expiresAt": 1698086400000
}
```

### 5.2 获取备份列表
**接口**: `GET /api/v1/backup`

**功能**: 获取历史备份列表

**响应数据**:
```json
{
  "backups": [
    {
      "backupId": "backup-uuid",
      "backupTime": 1698000000000,
      "fileSize": 10240000,
      "downloadUrl": "https://cdn.example.com/backups/xxx.zip",
      "expiresAt": 1698086400000
    }
  ]
}
```

### 5.3 恢复备份
**接口**: `POST /api/v1/backup/{backupId}/restore`

**功能**: 从备份恢复数据

**响应数据**:
```json
{
  "success": true,
  "restoredDiaries": 50,
  "restoredPhotos": 100,
  "message": "数据恢复成功"
}
```

### 5.4 删除备份
**接口**: `DELETE /api/v1/backup/{backupId}`

**功能**: 删除指定备份

**响应数据**:
```json
{
  "success": true,
  "message": "备份删除成功"
}
```

---

## 6. 数据模型定义

### 6.1 用户模型 (User)
```typescript
interface User {
  userId: string;              // 用户唯一ID
  deviceId: string;            // 设备唯一ID
  passwordHash: string;        // 加密后的密码
  biometricEnabled: boolean;   // 是否启用生物识别
  createdAt: number;           // 创建时间戳
  updatedAt: number;           // 更新时间戳
  lastLoginAt: number;         // 最后登录时间
}
```

### 6.2 日记模型 (Diary)
```typescript
interface Diary {
  diaryId: string;             // 日记唯一ID
  userId: string;              // 所属用户ID
  title: string;               // 标题（可选）
  content: string;             // 正文内容
  mood: MoodType;              // 心情类型
  tags: string[];              // 标签数组
  createdAt: number;           // 创建时间戳
  updatedAt: number;           // 更新时间戳
}

type MoodType = 'happy' | 'sad' | 'calm' | 'excited' | 'tired';
```

### 6.3 照片模型 (Photo)
```typescript
interface Photo {
  photoId: string;             // 照片唯一ID
  userId: string;              // 所属用户ID
  url: string;                 // 原图URL
  thumbnailUrl: string;        // 缩略图URL
  description?: string;        // 照片描述
  fileSize: number;            // 文件大小（字节）
  width: number;               // 图片宽度
  height: number;              // 图片高度
  format: string;              // 图片格式 (jpg/png/webp)
  exif?: PhotoExif;            // EXIF信息
  takenAt?: number;            // 拍摄时间
  uploadedAt: number;          // 上传时间戳
}

interface PhotoExif {
  camera?: string;             // 相机型号
  iso?: string;                // ISO值
  aperture?: string;           // 光圈
  shutterSpeed?: string;       // 快门速度
  focalLength?: string;        // 焦距
  location?: {                 // 位置信息
    latitude: number;
    longitude: number;
  };
}
```

---

## 7. 安全要求

### 7.1 认证安全
- 所有接口（除登录/注册外）必须携带有效的 JWT Token
- Token 有效期建议为 7 天
- 支持 Token 刷新机制
- 密码传输使用 HTTPS 加密
- 密码存储使用 bcrypt 或类似算法加密

### 7.2 数据安全
- 用户数据隔离：用户只能访问自己的数据
- 敏感信息加密存储
- 照片存储使用私有存储空间
- 照片URL包含临时访问凭证或签名

### 7.3 接口安全
- 实施请求频率限制（Rate Limiting）
- 防止 SQL 注入和 XSS 攻击
- 文件上传限制：
  - 单文件大小：10MB
  - 支持格式：jpg, jpeg, png, webp
  - 文件类型验证
- 敏感操作（删除、修改密码）需要二次验证

---

## 8. 性能要求

### 8.1 响应时间
- 接口平均响应时间 < 200ms
- 文件上传响应时间 < 3s（10MB文件）
- 列表查询响应时间 < 500ms

### 8.2 并发支持
- 支持至少 1000 并发用户
- 数据库连接池优化
- 使用 CDN 加速静态资源访问

### 8.3 数据限制
- 单个用户日记数量：无限制
- 单个用户照片数量：无限制
- 单篇日记内容长度：最大 100,000 字符
- 标签数量：每篇日记最多 10 个
- 标签长度：最大 20 字符

---

## 9. 测试用例建议

### 9.1 认证模块测试
- [ ] 注册成功
- [ ] 注册失败（密码格式不正确）
- [ ] 登录成功
- [ ] 登录失败（密码错误）
- [ ] Token 过期处理
- [ ] 修改密码成功/失败

### 9.2 日记模块测试
- [ ] 创建日记成功
- [ ] 创建日记失败（字段验证）
- [ ] 获取日记列表（分页）
- [ ] 搜索日记
- [ ] 更新日记
- [ ] 删除日记
- [ ] 批量删除日记

### 9.3 照片模块测试
- [ ] 上传照片成功
- [ ] 上传照片失败（文件过大/格式不支持）
- [ ] 批量上传照片
- [ ] 获取照片列表
- [ ] 删除照片
- [ ] 批量删除照片

---

## 10. 部署建议

### 10.1 技术栈推荐
- **后端框架**: Node.js (Express/Koa/NestJS) 或 Spring Boot
- **数据库**: PostgreSQL / MySQL
- **缓存**: Redis
- **文件存储**: AWS S3 / 阿里云OSS / 腾讯云COS
- **图片处理**: Sharp / ImageMagick

### 10.2 环境配置
```env
# 应用配置
APP_NAME=TreeHole
APP_ENV=production
APP_PORT=3000

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=treehole
DB_USER=treehole_user
DB_PASSWORD=secure_password

# JWT配置
JWT_SECRET=your-secret-key
JWT_EXPIRE=7d

# 文件存储配置
STORAGE_TYPE=s3
STORAGE_BUCKET=treehole-photos
STORAGE_REGION=us-east-1

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
```

---

## 11. 更新日志

### v1.0.0 (2024-10-23)
- 初始版本发布
- 完成核心功能接口定义
- 用户认证、日记管理、照片管理模块

---

## 附录

### A. 错误码详细说明
| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| 1001 | 用户名或密码错误 | 请检查输入 |
| 1002 | Token 已过期 | 请重新登录 |
| 1003 | Token 无效 | 请重新登录 |
| 2001 | 日记不存在 | 请检查日记ID |
| 2002 | 日记内容过长 | 减少内容长度 |
| 3001 | 照片不存在 | 请检查照片ID |
| 3002 | 文件格式不支持 | 仅支持 jpg/png/webp |
| 3003 | 文件过大 | 单文件最大10MB |
| 4001 | 请求频率过高 | 请稍后再试 |

### B. 开发优先级建议
1. **高优先级**: 
   - 用户认证模块
   - 日记CRUD接口
   - 照片上传和列表接口

2. **中优先级**:
   - 搜索和筛选功能
   - 标签管理
   - 统计功能

3. **低优先级**:
   - 备份和恢复功能
   - 高级设置
   - 数据导出

---

**文档版本**: v1.0.0  
**最后更新**: 2024-10-23  
**维护者**: 开发团队

