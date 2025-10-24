# API 对接快速开始

## 📋 前置条件

1. 后端 API 已部署并可访问
2. 已获取后端 API 地址
3. 网络权限已配置

## 🚀 快速开始

### 1. 配置后端地址

编辑文件：`products/default/src/main/ets/utils/HttpClient.ets`

```typescript
export class HttpConfig {
  // 修改为你的后端 API 地址
  public static readonly BASE_URL = 'https://your-api-domain.com';
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000;
}
```

### 2. 添加网络权限

编辑文件：`products/default/src/main/module.json5`

```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```

### 3. 基础使用示例

#### 认证流程

```typescript
import { AuthService } from '../services/AuthService';

// 初始化服务
const authService = new AuthService(getContext(this));
await authService.init();

// 用户注册
try {
  const response = await authService.register('123456', '123456');
  console.log('注册成功:', response.userId);
} catch (error) {
  console.error('注册失败:', error.message);
}

// 用户登录
try {
  const response = await authService.login('123456');
  console.log('登录成功:', response.userId);
} catch (error) {
  console.error('登录失败:', error.message);
}
```

#### 创建日记

```typescript
import { DiaryService } from '../services/DiaryService';
import { MoodType } from '../models/ApiTypes';

const diaryService = new DiaryService(getContext(this));

try {
  const diary = await diaryService.createDiary(
    '今天的心情',
    '今天天气很好！',
    'happy' as MoodType,
    ['生活', '心情']
  );
  console.log('日记创建成功:', diary.diaryId);
} catch (error) {
  console.error('创建失败:', error.message);
}
```

#### 上传照片

```typescript
import { PhotoService } from '../services/PhotoService';

const photoService = new PhotoService(getContext(this));

try {
  // 一站式选择并上传
  const result = await photoService.selectAndUploadPhotos(9);
  console.log(`上传成功: ${result.successCount}/${result.totalCount}`);
} catch (error) {
  console.error('上传失败:', error.message);
}
```

## 📚 已实现的服务

### ✅ AuthService - 认证服务
- 用户注册/登录
- 密码管理
- 生物识别设置
- Token 管理

### ✅ DiaryService - 日记服务
- CRUD 操作
- 搜索和筛选
- 标签管理
- 心情统计

### ✅ PhotoService - 照片服务
- 上传/删除照片
- 批量操作
- 照片列表
- 统计信息

### ✅ SettingsService - 设置服务
- 用户设置管理
- 主题配置
- 通知设置
- 隐私设置

### ✅ BackupService - 备份服务
- 创建/恢复备份
- 备份管理
- 下载备份

## 📖 详细文档

- **API 对接完整指南**: `API_INTEGRATION_GUIDE.md`
- **后端接口文档**: `API_REQUIREMENTS.md`
- **前端 API 文档**: `FRONTEND_API_GUIDE.md`

## 🔧 常用 API 方法

### 认证相关
```typescript
authService.register(password, confirmPassword)
authService.login(password)
authService.changePassword(oldPwd, newPwd, confirmPwd)
authService.logout()
authService.refreshToken()
```

### 日记相关
```typescript
diaryService.createDiary(title, content, mood, tags)
diaryService.getDiaryList(params)
diaryService.updateDiary(id, title, content, mood, tags)
diaryService.deleteDiary(id)
diaryService.searchDiaries(keyword)
diaryService.getAllTags()
diaryService.getMoodStats()
```

### 照片相关
```typescript
photoService.selectAndUploadPhotos(maxCount)
photoService.uploadPhoto(filePath, description)
photoService.getPhotoList(params)
photoService.deletePhoto(id)
photoService.getPhotoStats()
```

### 设置相关
```typescript
settingsService.getUserSettings()
settingsService.updateTheme(theme)
settingsService.updateNotifications(settings)
settingsService.getAppInfo()
```

### 备份相关
```typescript
backupService.createBackup()
backupService.getBackupList()
backupService.restoreBackup(id)
backupService.deleteBackup(id)
```

## ⚠️ 重要提示

1. **所有 API 调用都应该包裹在 try-catch 中**
2. **登录后自动保存 Token，后续请求会自动携带**
3. **Token 过期时调用 refreshToken() 刷新**
4. **文件上传限制为单个文件 10MB**
5. **生产环境必须使用 HTTPS**

## 🐛 调试技巧

### 查看请求日志

所有 HTTP 请求都会在日志中输出，可以通过 Logger 查看：

```typescript
// 在 HttpClient 中已经集成了详细的日志输出
// 查看 hilog 即可看到所有请求详情
```

### 测试连接

```typescript
// 测试后端连接是否正常
try {
  const appInfo = await settingsService.getAppInfo();
  console.log('后端连接正常:', appInfo.version);
} catch (error) {
  console.error('后端连接失败:', error.message);
}
```

## 📝 迁移指南

如果你的项目之前使用本地数据库，现在需要迁移到 API：

### 1. 更新服务引用

旧代码：
```typescript
// 使用本地数据库
const diary = await dbHelper.insertDiary(diaryModel);
```

新代码：
```typescript
// 使用 API
const diary = await diaryService.createDiary(title, content, mood, tags);
```

### 2. 数据模型适配

旧模型字段名已更新为符合后端 API 的命名：
- `id` → `diaryId` / `photoId`
- `createTime` → `createdAt`
- `updateTime` → `updatedAt`

### 3. 异步处理

所有 API 调用都是异步的，确保使用 async/await 或 Promise。

## 🎯 下一步

1. 阅读 `API_INTEGRATION_GUIDE.md` 了解详细用法
2. 查看 `API_REQUIREMENTS.md` 了解后端接口规范
3. 根据业务需求调整和扩展服务方法

---

**准备好了吗？** 现在就开始对接你的后端 API 吧！ 🚀

