# 树洞项目 - 前端对接接口文档

> **文档说明**：本文档为前端开发者（包括 AI）提供完整的后端接口对接指南。
> **服务地址**：`http://localhost:8000`（开发环境）
> **接口版本**：v1
> **更新时间**：2025-10-24

---

## 📋 目录

- [通用说明](#通用说明)
- [认证模块 (Auth)](#认证模块-auth)
  - [用户注册](#1-用户注册)
  - [用户登录](#2-用户登录)
  - [Token 刷新](#3-token-刷新)
  - [修改密码](#4-修改密码)
- [日记模块 (Diary)](#日记模块-diary)
  - [创建日记](#1-创建日记)
  - [日记列表](#2-日记列表)
  - [日记详情](#3-日记详情)
  - [更新日记](#4-更新日记)
  - [删除日记](#5-删除日记)
  - [批量删除](#6-批量删除)
  - [标签列表](#7-标签列表)
  - [心情统计](#8-心情统计)
- [错误码说明](#错误码说明)
- [前端实现建议](#前端实现建议)

---

## 通用说明

### 🌐 基础信息

| 项目 | 说明 |
|------|------|
| **协议** | HTTP/HTTPS |
| **数据格式** | JSON |
| **字符编码** | UTF-8 |
| **请求头** | `Content-Type: application/json` |
| **认证方式** | Bearer Token (JWT) |

### 🔐 认证机制

除了认证模块的接口外，其他所有接口都需要在请求头中携带 Token：

```http
Authorization: Bearer <your_token_here>
```

**Token 说明**：
- Token 有效期：**7 天**
- Token 过期后需要调用刷新接口或重新登录
- Token 通过登录接口获取

### 📦 统一响应格式

所有接口的响应格式统一为：

```json
{
  "code": 0,
  "message": "success",
  "data": { /* 具体业务数据 */ }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | number | 状态码，0 表示成功，非 0 表示失败 |
| `message` | string | 提示信息 |
| `data` | object/array/null | 业务数据，失败时可能为 null |

### ⚠️ 错误处理

当 `code != 0` 时，表示请求失败，需要展示 `message` 给用户。

常见错误码：
- `0`：成功
- `50`：请求参数错误
- `401`：未授权或 Token 失效
- `404`：资源不存在
- `500`：服务器内部错误

---

## 认证模块 (Auth)

### 1. 用户注册

**接口路径**：`POST /auth/register`

**请求头**：
```http
Content-Type: application/json
```

**请求参数**：
```json
{
  "username": "testuser",
  "password": "abc123",
  "deviceId": "device-unique-id-123"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `username` | string | ✅ | 用户名，2-20 个字符 |
| `password` | string | ✅ | 密码，**必须为 6 位字母和数字的组合**（如 `abc123`、`A1B2C3`） |
| `deviceId` | string | ✅ | 设备唯一标识，用于区分不同设备登录 |

**密码规则**：
- ✅ 长度：恰好 6 位
- ✅ 字符：只能包含字母（大小写）和数字
- ✅ 允许：`abc123`、`ABC123`、`Aa1Bb2`、`123456`、`abcdef`
- ❌ 不允许：`abc@123`（特殊字符）、`abc 12`（空格）、`abc12`（少于6位）

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "userId": 1,
    "username": "testuser",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "biometricEnabled": false
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `userId` | number | 用户 ID |
| `username` | string | 用户名 |
| `token` | string | JWT Token，有效期 7 天 |
| `biometricEnabled` | boolean | 是否开启生物识别（固定为 false，不实现） |

**失败响应**：
```json
{
  "code": 50,
  "message": "用户名已存在",
  "data": null
}
```

**curl 示例**：
```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "abc123",
    "deviceId": "device-001"
  }'
```

---

### 2. 用户登录

**接口路径**：`POST /auth/login`

**请求参数**：
```json
{
  "username": "testuser",
  "password": "abc123",
  "deviceId": "device-unique-id-123"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `username` | string | ✅ | 用户名 |
| `password` | string | ✅ | 密码，6 位字母和数字组合 |
| `deviceId` | string | ✅ | 设备唯一标识 |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "userId": 1,
    "username": "testuser",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "biometricEnabled": false
  }
}
```

**失败响应**：
```json
{
  "code": 50,
  "message": "用户名或密码错误",
  "data": null
}
```

**curl 示例**：
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "abc123",
    "deviceId": "device-001"
  }'
```

---

### 3. Token 刷新

**接口路径**：`POST /auth/refresh`

**请求头**：
```http
Content-Type: application/json
Authorization: Bearer <old_token>
```

**请求参数**：
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `token` | string | ✅ | 旧的 Token（即将过期或已过期） |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresAt": 1729900800
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `token` | string | 新的 JWT Token |
| `expiresAt` | number | 过期时间戳（秒） |

**失败响应**：
```json
{
  "code": 401,
  "message": "Token 无效或已过期",
  "data": null
}
```

**curl 示例**：
```bash
curl -X POST http://localhost:8000/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "token": "YOUR_TOKEN"
  }'
```

---

### 4. 修改密码

**接口路径**：`PUT /auth/password`

**请求头**：
```http
Content-Type: application/json
Authorization: Bearer <your_token>
```

**请求参数**：
```json
{
  "oldPassword": "abc123",
  "newPassword": "xyz789"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `oldPassword` | string | ✅ | 旧密码，6 位字母和数字组合 |
| `newPassword` | string | ✅ | 新密码，6 位字母和数字组合 |

**成功响应**：
```json
{
  "code": 0,
  "message": "密码修改成功",
  "data": null
}
```

**失败响应**：
```json
{
  "code": 50,
  "message": "旧密码错误",
  "data": null
}
```

**curl 示例**：
```bash
curl -X PUT http://localhost:8000/auth/password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "oldPassword": "abc123",
    "newPassword": "xyz789"
  }'
```

---

## 日记模块 (Diary)

> ⚠️ **注意**：日记模块的所有接口都需要在请求头中携带 Token。

### 1. 创建日记

**接口路径**：`POST /diaries`

**请求头**：
```http
Content-Type: application/json
Authorization: Bearer <your_token>
```

**请求参数**：
```json
{
  "title": "今天的心情",
  "content": "今天天气很好，心情也不错。学习了新技术，感觉很充实。",
  "mood": "happy",
  "tags": ["生活", "学习"],
  "weather": "晴天",
  "location": "北京",
  "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"]
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `title` | string | ✅ | 日记标题，最多 100 个字符 |
| `content` | string | ✅ | 日记内容，最多 10000 个字符 |
| `mood` | string | ✅ | 心情，枚举值：`happy`/`sad`/`calm`/`excited`/`tired` |
| `tags` | array | ❌ | 标签数组，最多 10 个，每个标签最长 20 字符 |
| `weather` | string | ❌ | 天气，最多 50 个字符 |
| `location` | string | ❌ | 地点，最多 100 个字符 |
| `images` | array | ❌ | 图片 URL 数组，最多 9 张 |

**心情枚举值说明**：

| 值 | 中文含义 |
|----|---------|
| `happy` | 开心 |
| `sad` | 伤心 |
| `calm` | 平静 |
| `excited` | 兴奋 |
| `tired` | 疲惫 |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | number | 新创建的日记 ID |

**失败响应**：
```json
{
  "code": 50,
  "message": "标题不能为空",
  "data": null
}
```

**curl 示例**：
```bash
curl -X POST http://localhost:8000/diaries \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "今天的心情",
    "content": "今天很开心",
    "mood": "happy",
    "tags": ["生活"]
  }'
```

---

### 2. 日记列表

**接口路径**：`GET /diaries`

**请求头**：
```http
Authorization: Bearer <your_token>
```

**请求参数**（Query 参数）：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `page` | number | ❌ | 1 | 页码，从 1 开始 |
| `pageSize` | number | ❌ | 10 | 每页数量，最大 100 |
| `keyword` | string | ❌ | - | 关键词搜索（标题、内容） |
| `mood` | string | ❌ | - | 心情筛选：`happy`/`sad`/`calm`/`excited`/`tired` |
| `tags` | string | ❌ | - | 标签筛选，多个标签用逗号分隔，如 `生活,学习` |
| `startDate` | string | ❌ | - | 开始日期，格式：`YYYY-MM-DD`，如 `2024-01-01` |
| `endDate` | string | ❌ | - | 结束日期，格式：`YYYY-MM-DD`，如 `2024-12-31` |

**完整 URL 示例**：
```
GET /diaries?page=1&pageSize=10&keyword=开心&mood=happy&tags=生活,学习&startDate=2024-01-01&endDate=2024-12-31
```

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "title": "今天的心情",
        "contentPreview": "今天天气很好，心情也不错。学习了新技术，感觉很充实。",
        "mood": "happy",
        "tags": ["生活", "学习"],
        "weather": "晴天",
        "location": "北京",
        "images": ["https://example.com/image1.jpg"],
        "createdAt": "2024-10-20T10:30:00Z",
        "updatedAt": "2024-10-20T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 10,
      "total": 100,
      "totalPages": 10
    }
  }
}
```

**响应字段说明**：

**items 数组中的日记项**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | number | 日记 ID |
| `title` | string | 标题 |
| `contentPreview` | string | 内容预览（前 100 个字符） |
| `mood` | string | 心情 |
| `tags` | array | 标签数组 |
| `weather` | string | 天气 |
| `location` | string | 地点 |
| `images` | array | 图片 URL 数组 |
| `createdAt` | string | 创建时间（ISO 8601 格式） |
| `updatedAt` | string | 更新时间（ISO 8601 格式） |

**pagination 分页信息**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `page` | number | 当前页码 |
| `pageSize` | number | 每页数量 |
| `total` | number | 总记录数 |
| `totalPages` | number | 总页数 |

**curl 示例**：
```bash
# 基础查询
curl -X GET "http://localhost:8000/diaries?page=1&pageSize=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 带搜索条件
curl -X GET "http://localhost:8000/diaries?keyword=开心&mood=happy&tags=生活" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 3. 日记详情

**接口路径**：`GET /diaries/{id}`

**请求头**：
```http
Authorization: Bearer <your_token>
```

**路径参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | number | ✅ | 日记 ID |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1,
    "title": "今天的心情",
    "content": "今天天气很好，心情也不错。学习了新技术，感觉很充实。这是完整的内容...",
    "mood": "happy",
    "tags": ["生活", "学习"],
    "weather": "晴天",
    "location": "北京",
    "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
    "createdAt": "2024-10-20T10:30:00Z",
    "updatedAt": "2024-10-20T10:30:00Z"
  }
}
```

**字段说明**：与列表接口类似，但 `content` 是完整内容（不是预览）。

**失败响应**：
```json
{
  "code": 404,
  "message": "日记不存在",
  "data": null
}
```

**curl 示例**：
```bash
curl -X GET http://localhost:8000/diaries/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 4. 更新日记

**接口路径**：`PUT /diaries/{id}`

**请求头**：
```http
Content-Type: application/json
Authorization: Bearer <your_token>
```

**路径参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | number | ✅ | 日记 ID |

**请求参数**：
```json
{
  "title": "修改后的标题",
  "content": "修改后的内容",
  "mood": "calm",
  "tags": ["生活", "思考"],
  "weather": "多云",
  "location": "上海",
  "images": ["https://example.com/new-image.jpg"]
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `title` | string | ✅ | 标题，最多 100 个字符 |
| `content` | string | ✅ | 内容，最多 10000 个字符 |
| `mood` | string | ✅ | 心情 |
| `tags` | array | ❌ | 标签数组 |
| `weather` | string | ❌ | 天气 |
| `location` | string | ❌ | 地点 |
| `images` | array | ❌ | 图片 URL 数组 |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```

**失败响应**：
```json
{
  "code": 404,
  "message": "日记不存在或无权限修改",
  "data": null
}
```

**curl 示例**：
```bash
curl -X PUT http://localhost:8000/diaries/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "修改后的标题",
    "content": "修改后的内容",
    "mood": "calm"
  }'
```

---

### 5. 删除日记

**接口路径**：`DELETE /diaries/{id}`

**请求头**：
```http
Authorization: Bearer <your_token>
```

**路径参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | number | ✅ | 日记 ID |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```

**失败响应**：
```json
{
  "code": 404,
  "message": "日记不存在或无权限删除",
  "data": null
}
```

**curl 示例**：
```bash
curl -X DELETE http://localhost:8000/diaries/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 6. 批量删除

**接口路径**：`DELETE /diaries/batch`

**请求头**：
```http
Content-Type: application/json
Authorization: Bearer <your_token>
```

**请求参数**：
```json
{
  "ids": [1, 2, 3, 4, 5]
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `ids` | array | ✅ | 要删除的日记 ID 数组 |

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "deletedCount": 5
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `deletedCount` | number | 成功删除的数量 |

**失败响应**：
```json
{
  "code": 50,
  "message": "ids 不能为空",
  "data": null
}
```

**curl 示例**：
```bash
curl -X DELETE http://localhost:8000/diaries/batch \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "ids": [1, 2, 3]
  }'
```

---

### 7. 标签列表

**接口路径**：`GET /diaries/tags`

**请求头**：
```http
Authorization: Bearer <your_token>
```

**请求参数**：无

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "tags": [
      {
        "name": "生活",
        "count": 25
      },
      {
        "name": "学习",
        "count": 18
      },
      {
        "name": "工作",
        "count": 12
      }
    ]
  }
}
```

**字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 标签名称 |
| `count` | number | 使用次数 |

**curl 示例**：
```bash
curl -X GET http://localhost:8000/diaries/tags \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 8. 心情统计

**接口路径**：`GET /diaries/mood-stats`

**请求头**：
```http
Authorization: Bearer <your_token>
```

**请求参数**（Query 参数）：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `startDate` | string | ❌ | 开始日期，格式：`YYYY-MM-DD` |
| `endDate` | string | ❌ | 结束日期，格式：`YYYY-MM-DD` |

**URL 示例**：
```
GET /diaries/mood-stats?startDate=2024-01-01&endDate=2024-12-31
```

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "stats": [
      {
        "mood": "happy",
        "count": 45,
        "percentage": 45.0
      },
      {
        "mood": "calm",
        "count": 30,
        "percentage": 30.0
      },
      {
        "mood": "excited",
        "count": 15,
        "percentage": 15.0
      },
      {
        "mood": "tired",
        "count": 8,
        "percentage": 8.0
      },
      {
        "mood": "sad",
        "count": 2,
        "percentage": 2.0
      }
    ],
    "total": 100
  }
}
```

**字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `mood` | string | 心情类型 |
| `count` | number | 该心情的日记数量 |
| `percentage` | number | 占比百分比 |
| `total` | number | 总日记数量 |

**curl 示例**：
```bash
# 查询所有时间的统计
curl -X GET http://localhost:8000/diaries/mood-stats \
  -H "Authorization: Bearer YOUR_TOKEN"

# 查询指定时间范围
curl -X GET "http://localhost:8000/diaries/mood-stats?startDate=2024-01-01&endDate=2024-12-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 错误码说明

| 错误码 | 说明 | 常见场景 |
|--------|------|----------|
| `0` | 成功 | 请求处理成功 |
| `50` | 请求参数错误 | 参数验证失败、缺少必填字段 |
| `401` | 未授权 | Token 无效、Token 过期、未登录 |
| `403` | 禁止访问 | 无权限操作该资源 |
| `404` | 资源不存在 | 日记不存在、用户不存在 |
| `500` | 服务器错误 | 数据库错误、服务异常 |

**错误响应示例**：
```json
{
  "code": 50,
  "message": "密码必须为6位字母和数字的组合",
  "data": null
}
```

---

## 前端实现建议

### 🛠️ 1. 封装 HTTP 请求工具

**建议封装统一的请求方法**，包含以下功能：
- 自动添加 Token 到请求头
- 统一处理错误响应
- 自动重试 Token 刷新

**TypeScript 示例**：

```typescript
// api/request.ts
import axios from 'axios';

const BASE_URL = 'http://localhost:8000';

// 创建 axios 实例
const request = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器 - 添加 Token
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器 - 统一处理错误
request.interceptors.response.use(
  (response) => {
    const { code, message, data } = response.data;
    
    if (code === 0) {
      return data; // 只返回 data 部分
    } else {
      // 显示错误提示
      console.error(message);
      return Promise.reject(new Error(message));
    }
  },
  async (error) => {
    if (error.response?.status === 401) {
      // Token 过期，尝试刷新或跳转登录
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default request;
```

---

### 🔐 2. 认证模块封装

**文件**：`api/auth.ts`

```typescript
import request from './request';

// 注册
export const register = (data: {
  username: string;
  password: string;
  deviceId: string;
}) => {
  return request.post('/auth/register', data);
};

// 登录
export const login = (data: {
  username: string;
  password: string;
  deviceId: string;
}) => {
  return request.post('/auth/login', data);
};

// Token 刷新
export const refreshToken = (token: string) => {
  return request.post('/auth/refresh', { token });
};

// 修改密码
export const changePassword = (data: {
  oldPassword: string;
  newPassword: string;
}) => {
  return request.put('/auth/password', data);
};
```

**使用示例**：

```typescript
import { login } from '@/api/auth';

// 登录
const handleLogin = async () => {
  try {
    const res = await login({
      username: 'testuser',
      password: 'abc123',
      deviceId: 'device-001'
    });
    
    // 保存 Token
    localStorage.setItem('token', res.token);
    localStorage.setItem('userId', res.userId);
    
    console.log('登录成功', res);
  } catch (error) {
    console.error('登录失败', error);
  }
};
```

---

### 📝 3. 日记模块封装

**文件**：`api/diary.ts`

```typescript
import request from './request';

// 创建日记
export const createDiary = (data: {
  title: string;
  content: string;
  mood: string;
  tags?: string[];
  weather?: string;
  location?: string;
  images?: string[];
}) => {
  return request.post('/diaries', data);
};

// 日记列表
export const getDiaryList = (params: {
  page?: number;
  pageSize?: number;
  keyword?: string;
  mood?: string;
  tags?: string;
  startDate?: string;
  endDate?: string;
}) => {
  return request.get('/diaries', { params });
};

// 日记详情
export const getDiaryDetail = (id: number) => {
  return request.get(`/diaries/${id}`);
};

// 更新日记
export const updateDiary = (id: number, data: {
  title: string;
  content: string;
  mood: string;
  tags?: string[];
  weather?: string;
  location?: string;
  images?: string[];
}) => {
  return request.put(`/diaries/${id}`, data);
};

// 删除日记
export const deleteDiary = (id: number) => {
  return request.delete(`/diaries/${id}`);
};

// 批量删除
export const batchDeleteDiary = (ids: number[]) => {
  return request.delete('/diaries/batch', { data: { ids } });
};

// 标签列表
export const getDiaryTags = () => {
  return request.get('/diaries/tags');
};

// 心情统计
export const getMoodStats = (params?: {
  startDate?: string;
  endDate?: string;
}) => {
  return request.get('/diaries/mood-stats', { params });
};
```

**使用示例**：

```typescript
import { getDiaryList, createDiary } from '@/api/diary';

// 查询日记列表
const fetchDiaries = async () => {
  try {
    const res = await getDiaryList({
      page: 1,
      pageSize: 10,
      keyword: '开心',
      mood: 'happy'
    });
    
    console.log('日记列表', res.items);
    console.log('分页信息', res.pagination);
  } catch (error) {
    console.error('查询失败', error);
  }
};

// 创建日记
const handleCreate = async () => {
  try {
    const res = await createDiary({
      title: '今天的心情',
      content: '今天很开心',
      mood: 'happy',
      tags: ['生活', '学习']
    });
    
    console.log('创建成功，日记ID:', res.id);
  } catch (error) {
    console.error('创建失败', error);
  }
};
```

---

### 📋 4. TypeScript 类型定义

**文件**：`types/api.ts`

```typescript
// 通用响应格式
export interface ApiResponse<T = any> {
  code: number;
  message: string;
  data: T;
}

// 用户信息
export interface UserInfo {
  userId: number;
  username: string;
  token: string;
  biometricEnabled: boolean;
}

// 日记项
export interface DiaryItem {
  id: number;
  title: string;
  contentPreview?: string; // 列表时有
  content?: string; // 详情时有
  mood: 'happy' | 'sad' | 'calm' | 'excited' | 'tired';
  tags: string[];
  weather?: string;
  location?: string;
  images: string[];
  createdAt: string;
  updatedAt: string;
}

// 日记列表响应
export interface DiaryListResponse {
  items: DiaryItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
}

// 标签项
export interface TagItem {
  name: string;
  count: number;
}

// 心情统计项
export interface MoodStatItem {
  mood: string;
  count: number;
  percentage: number;
}

// 心情统计响应
export interface MoodStatsResponse {
  stats: MoodStatItem[];
  total: number;
}
```

---

### 🎨 5. 前端表单验证

**密码验证规则**：

```typescript
// 密码验证函数
export const validatePassword = (password: string): boolean => {
  // 必须为 6 位字母和数字的组合
  const regex = /^[a-zA-Z0-9]{6}$/;
  return regex.test(password);
};

// 使用示例（React）
const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  const password = e.target.value;
  
  if (!validatePassword(password)) {
    setError('密码必须为6位字母和数字的组合');
  } else {
    setError('');
  }
};
```

**标签验证**：

```typescript
// 标签验证函数
export const validateTags = (tags: string[]): { valid: boolean; error?: string } => {
  if (tags.length > 10) {
    return { valid: false, error: '标签最多10个' };
  }
  
  for (const tag of tags) {
    if (tag.length > 20) {
      return { valid: false, error: '每个标签最长20个字符' };
    }
  }
  
  return { valid: true };
};
```

---

### 💡 6. 常见问题处理

#### Q1: Token 过期如何处理？

**方案 A**：自动刷新（推荐）

```typescript
// 在响应拦截器中自动刷新
request.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      const oldToken = localStorage.getItem('token');
      
      try {
        // 尝试刷新 Token
        const res = await refreshToken(oldToken);
        localStorage.setItem('token', res.token);
        
        // 重新发起原请求
        error.config.headers.Authorization = `Bearer ${res.token}`;
        return request(error.config);
      } catch (refreshError) {
        // 刷新失败，跳转登录
        localStorage.removeItem('token');
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);
```

**方案 B**：提示用户重新登录

```typescript
if (error.response?.status === 401) {
  message.error('登录已过期，请重新登录');
  localStorage.removeItem('token');
  router.push('/login');
}
```

---

#### Q2: 如何获取 deviceId？

```typescript
// 生成唯一设备 ID（浏览器）
export const getDeviceId = (): string => {
  let deviceId = localStorage.getItem('deviceId');
  
  if (!deviceId) {
    // 生成随机 UUID
    deviceId = 'device-' + Math.random().toString(36).substr(2, 9);
    localStorage.setItem('deviceId', deviceId);
  }
  
  return deviceId;
};

// 使用
const deviceId = getDeviceId();
await login({ username, password, deviceId });
```

---

#### Q3: 日期格式如何处理？

**前端发送给后端**（查询参数）：
```typescript
// 使用 YYYY-MM-DD 格式
const startDate = '2024-01-01';
const endDate = '2024-12-31';

getDiaryList({ startDate, endDate });
```

**后端返回的时间**（ISO 8601）：
```typescript
// 后端返回：2024-10-20T10:30:00Z
// 前端格式化显示
import dayjs from 'dayjs';

const formattedDate = dayjs('2024-10-20T10:30:00Z').format('YYYY-MM-DD HH:mm:ss');
// 输出：2024-10-20 10:30:00
```

---

#### Q4: 图片上传如何处理？

本接口不提供图片上传功能，需要前端先将图片上传到图床或 OSS，然后将 URL 传给后端。

**推荐方案**：
1. 使用阿里云 OSS / 腾讯云 COS
2. 使用免费图床（如 ImgBB、SM.MS）
3. 自建图片服务

```typescript
// 伪代码示例
const uploadImage = async (file: File): Promise<string> => {
  // 上传到图床
  const formData = new FormData();
  formData.append('image', file);
  
  const res = await fetch('https://your-image-host.com/upload', {
    method: 'POST',
    body: formData,
  });
  
  const data = await res.json();
  return data.url; // 返回图片 URL
};

// 创建日记时传入图片 URL
const imageUrls = await Promise.all(files.map(uploadImage));
await createDiary({
  title: '...',
  content: '...',
  images: imageUrls, // ['https://...', 'https://...']
});
```

---

### ✅ 7. 测试清单

在完成前端开发后，建议按以下清单测试：

**认证模块**：
- ✅ 注册新用户（测试密码验证）
- ✅ 登录（测试 Token 获取）
- ✅ Token 刷新（测试自动刷新机制）
- ✅ 修改密码（测试旧密码验证）

**日记模块**：
- ✅ 创建日记（测试所有字段）
- ✅ 列表查询（测试分页、搜索、筛选）
- ✅ 详情查询
- ✅ 更新日记
- ✅ 删除日记
- ✅ 批量删除
- ✅ 标签列表
- ✅ 心情统计

**错误处理**：
- ✅ Token 过期处理
- ✅ 参数验证错误提示
- ✅ 网络错误提示
- ✅ 权限错误处理

---

## 📚 附录

### A. 心情枚举对照表

| 英文值 | 中文 | 图标建议 | 颜色建议 |
|--------|------|---------|---------|
| `happy` | 开心 | 😊 | #FFD700 (金黄色) |
| `sad` | 伤心 | 😢 | #4682B4 (钢青色) |
| `calm` | 平静 | 😌 | #90EE90 (浅绿色) |
| `excited` | 兴奋 | 🤩 | #FF6347 (番茄红) |
| `tired` | 疲惫 | 😴 | #A9A9A9 (灰色) |

---

### B. 完整请求示例（JavaScript）

```javascript
// 完整的注册 + 登录 + 创建日记流程

// 1. 注册
const registerRes = await fetch('http://localhost:8000/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'testuser',
    password: 'abc123',
    deviceId: 'device-001'
  })
});
const registerData = await registerRes.json();
console.log('注册成功', registerData);

// 2. 登录
const loginRes = await fetch('http://localhost:8000/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'testuser',
    password: 'abc123',
    deviceId: 'device-001'
  })
});
const loginData = await loginRes.json();
const token = loginData.data.token;
console.log('登录成功，Token:', token);

// 3. 创建日记（需要 Token）
const createRes = await fetch('http://localhost:8000/diaries', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    title: '我的第一篇日记',
    content: '今天是个好日子',
    mood: 'happy',
    tags: ['生活']
  })
});
const createData = await createRes.json();
console.log('日记创建成功', createData);
```

---

### C. Postman/Apifox 导入配置

**环境变量**：
```json
{
  "base_url": "http://localhost:8000",
  "token": ""
}
```

**全局请求头**：
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {{token}}"
}
```

---

## 🎯 总结

### 核心要点

1. **认证**：除认证接口外，所有接口都需要 Token
2. **密码规则**：6 位字母和数字组合（如 `abc123`）
3. **心情枚举**：`happy`/`sad`/`calm`/`excited`/`tired`
4. **数据格式**：统一 JSON 格式，响应包含 `code`/`message`/`data`
5. **错误处理**：通过 `code` 判断成功/失败，显示 `message` 给用户

### 快速开始

1. **启动后端服务**：`go run main.go`
2. **访问 Swagger**：http://localhost:8000/swagger
3. **注册账号**：POST `/auth/register`
4. **获取 Token**：POST `/auth/login`
5. **开始使用**：在请求头中携带 Token 调用其他接口

---

## 📞 支持

- **Swagger 文档**：http://localhost:8000/swagger
- **测试脚本**：`./test_password_validation.sh`
- **更新日志**：查看 `CHANGELOG_PASSWORD_UPDATE.md`

---

**文档版本**：v1.0.0  
**最后更新**：2025-10-24  
**维护者**：后端开发团队

