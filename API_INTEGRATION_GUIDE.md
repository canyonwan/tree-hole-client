# API 对接指南

## 概述

本文档说明如何使用已实现的前端 API 服务层对接后端接口。所有服务都已按照 `API_REQUIREMENTS.md` 文档完整实现。

## 目录结构

```
products/default/src/main/ets/
├── models/
│   ├── ApiTypes.ets          # API 类型定义
│   ├── UserModel.ets          # 用户模型
│   ├── DiaryModel.ets         # 日记模型
│   └── PhotoModel.ets         # 照片模型
├── services/
│   ├── AuthService.ets        # 认证服务
│   ├── DiaryService.ets       # 日记服务
│   ├── PhotoService.ets       # 照片服务
│   ├── SettingsService.ets    # 设置服务
│   └── BackupService.ets      # 备份服务
└── utils/
    └── HttpClient.ets         # HTTP 客户端
```

---

## 配置后端地址

在使用前，需要先配置后端 API 地址：

```typescript
// 文件：products/default/src/main/ets/utils/HttpClient.ets

export class HttpConfig {
  // 修改为你的后端 API 地址
  public static readonly BASE_URL = 'https://your-api-domain.com';
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000;
}
```

---

## 1. 认证服务（AuthService）

### 初始化

```typescript
import { AuthService } from '../services/AuthService';

const authService = new AuthService(getContext(this));
await authService.init();
```

### 用户注册

```typescript
try {
  const response = await authService.register('123456', '123456');
  console.log('注册成功:', response.userId);
  console.log('Token:', response.token);
} catch (error) {
  console.error('注册失败:', error.message);
}
```

### 密码登录

```typescript
try {
  const response = await authService.login('123456');
  console.log('登录成功:', response.userId);
  console.log('生物识别状态:', response.biometricEnabled);
} catch (error) {
  console.error('登录失败:', error.message);
}
```

### 修改密码

```typescript
try {
  const success = await authService.changePassword('123456', '654321', '654321');
  if (success) {
    console.log('密码修改成功');
  }
} catch (error) {
  console.error('修改密码失败:', error.message);
}
```

### 生物识别设置

```typescript
// 启用生物识别
try {
  const response = await authService.setBiometricEnabled(true, 'device-bio-id');
  console.log('生物识别已启用:', response.biometricEnabled);
} catch (error) {
  console.error('设置失败:', error.message);
}

// 执行生物识别认证
const isAuthenticated = await authService.authenticateWithBiometric();
if (isAuthenticated) {
  console.log('生物识别认证成功');
}
```

### 退出登录

```typescript
await authService.logout();
```

---

## 2. 日记服务（DiaryService）

### 初始化

```typescript
import { DiaryService } from '../services/DiaryService';
import { MoodType } from '../models/ApiTypes';

const diaryService = new DiaryService(getContext(this));
```

### 创建日记

```typescript
try {
  const diary = await diaryService.createDiary(
    '今天的心情',           // 标题（可选）
    '今天天气很好...',      // 内容
    'happy' as MoodType,    // 心情
    ['生活', '工作']        // 标签
  );
  console.log('日记创建成功:', diary.diaryId);
} catch (error) {
  console.error('创建失败:', error.message);
}
```

### 获取日记列表

```typescript
try {
  const response = await diaryService.getDiaryList({
    page: 1,
    pageSize: 20,
    keyword: '心情',
    mood: 'happy' as MoodType,
    sortBy: 'createdAt',
    sortOrder: 'desc'
  });
  
  console.log('总数:', response.total);
  console.log('日记列表:', response.items);
} catch (error) {
  console.error('获取失败:', error.message);
}
```

### 获取日记详情

```typescript
try {
  const diary = await diaryService.getDiaryById('diary-uuid');
  console.log('日记内容:', diary.content);
} catch (error) {
  console.error('获取失败:', error.message);
}
```

### 更新日记

```typescript
try {
  const updatedDiary = await diaryService.updateDiary(
    'diary-uuid',
    '更新的标题',
    '更新的内容',
    'calm' as MoodType,
    ['生活']
  );
  console.log('更新成功:', updatedDiary.updatedAt);
} catch (error) {
  console.error('更新失败:', error.message);
}
```

### 删除日记

```typescript
try {
  await diaryService.deleteDiary('diary-uuid');
  console.log('删除成功');
} catch (error) {
  console.error('删除失败:', error.message);
}
```

### 批量删除日记

```typescript
try {
  const result = await diaryService.batchDeleteDiaries([
    'diary-uuid-1',
    'diary-uuid-2'
  ]);
  console.log('删除数量:', result.deletedCount);
} catch (error) {
  console.error('批量删除失败:', error.message);
}
```

### 搜索日记

```typescript
try {
  const results = await diaryService.searchDiaries('关键词', 1, 20);
  console.log('搜索结果:', results.items);
} catch (error) {
  console.error('搜索失败:', error.message);
}
```

### 按心情筛选

```typescript
try {
  const results = await diaryService.getDiariesByMood('happy' as MoodType);
  console.log('开心的日记:', results.items);
} catch (error) {
  console.error('筛选失败:', error.message);
}
```

### 按标签筛选

```typescript
try {
  const results = await diaryService.getDiariesByTags(['生活', '工作']);
  console.log('标签筛选结果:', results.items);
} catch (error) {
  console.error('筛选失败:', error.message);
}
```

### 获取所有标签

```typescript
try {
  const tagsResponse = await diaryService.getAllTags();
  tagsResponse.tags.forEach(tag => {
    console.log(`${tag.name}: ${tag.count}次`);
  });
} catch (error) {
  console.error('获取标签失败:', error.message);
}
```

### 获取心情统计

```typescript
try {
  const stats = await diaryService.getMoodStats(startDate, endDate);
  console.log('总日记数:', stats.totalDiaries);
  stats.stats.forEach(stat => {
    console.log(`${stat.mood}: ${stat.count}次 (${stat.percentage}%)`);
  });
} catch (error) {
  console.error('获取统计失败:', error.message);
}
```

---

## 3. 照片服务（PhotoService）

### 初始化

```typescript
import { PhotoService } from '../services/PhotoService';

const photoService = new PhotoService(getContext(this));
```

### 选择并上传照片

```typescript
try {
  // 一站式选择并上传
  const result = await photoService.selectAndUploadPhotos(9);
  console.log(`上传成功: ${result.successCount}/${result.totalCount}`);
  console.log('照片列表:', result.photos);
} catch (error) {
  console.error('上传失败:', error.message);
}
```

### 上传单张照片

```typescript
try {
  const photo = await photoService.uploadPhoto(
    'file:///path/to/photo.jpg',
    '照片描述',
    Date.now()
  );
  console.log('照片ID:', photo.photoId);
  console.log('照片URL:', photo.url);
  console.log('缩略图URL:', photo.thumbnailUrl);
} catch (error) {
  console.error('上传失败:', error.message);
}
```

### 批量上传照片

```typescript
try {
  const filePaths = [
    'file:///path/to/photo1.jpg',
    'file:///path/to/photo2.jpg'
  ];
  
  const result = await photoService.batchUploadPhotos(filePaths);
  console.log(`成功: ${result.successCount}, 失败: ${result.failedCount}`);
} catch (error) {
  console.error('批量上传失败:', error.message);
}
```

### 获取照片列表

```typescript
try {
  const response = await photoService.getPhotoList({
    page: 1,
    pageSize: 30,
    sortBy: 'takenAt',
    sortOrder: 'desc'
  });
  
  console.log('总数:', response.total);
  console.log('照片列表:', response.items);
} catch (error) {
  console.error('获取失败:', error.message);
}
```

### 获取照片详情

```typescript
try {
  const photo = await photoService.getPhotoById('photo-uuid');
  console.log('照片信息:', photo);
  console.log('EXIF信息:', photo.exif);
} catch (error) {
  console.error('获取失败:', error.message);
}
```

### 更新照片信息

```typescript
try {
  const updatedPhoto = await photoService.updatePhoto(
    'photo-uuid',
    '新的照片描述'
  );
  console.log('更新成功:', updatedPhoto);
} catch (error) {
  console.error('更新失败:', error.message);
}
```

### 删除照片

```typescript
try {
  await photoService.deletePhoto('photo-uuid');
  console.log('删除成功');
} catch (error) {
  console.error('删除失败:', error.message);
}
```

### 批量删除照片

```typescript
try {
  const result = await photoService.batchDeletePhotos([
    'photo-uuid-1',
    'photo-uuid-2'
  ]);
  console.log('删除数量:', result.deletedCount);
} catch (error) {
  console.error('批量删除失败:', error.message);
}
```

### 获取照片统计

```typescript
try {
  const stats = await photoService.getPhotoStats();
  console.log('总照片数:', stats.totalPhotos);
  console.log('总大小:', stats.totalSize);
  console.log('格式分布:', stats.formatsDistribution);
} catch (error) {
  console.error('获取统计失败:', error.message);
}
```

---

## 4. 设置服务（SettingsService）

### 初始化

```typescript
import { SettingsService } from '../services/SettingsService';

const settingsService = new SettingsService(getContext(this));
```

### 获取用户设置

```typescript
try {
  const settings = await settingsService.getUserSettings();
  console.log('主题:', settings.theme);
  console.log('生物识别:', settings.biometricEnabled);
  console.log('自动备份:', settings.autoBackup);
  console.log('通知设置:', settings.notifications);
} catch (error) {
  console.error('获取设置失败:', error.message);
}
```

### 更新主题

```typescript
try {
  await settingsService.updateTheme('dark');
  console.log('主题更新成功');
} catch (error) {
  console.error('更新失败:', error.message);
}
```

### 更新自动备份设置

```typescript
try {
  await settingsService.updateAutoBackup(true, 'daily');
  console.log('自动备份设置更新成功');
} catch (error) {
  console.error('更新失败:', error.message);
}
```

### 更新通知设置

```typescript
try {
  await settingsService.updateNotifications({
    enabled: true,
    reminderTime: '21:00'
  });
  console.log('通知设置更新成功');
} catch (error) {
  console.error('更新失败:', error.message);
}
```

### 更新隐私设置

```typescript
try {
  await settingsService.updatePrivacy({
    dataEncryption: true,
    hidePreviewInTaskSwitcher: true
  });
  console.log('隐私设置更新成功');
} catch (error) {
  console.error('更新失败:', error.message);
}
```

### 获取应用信息

```typescript
try {
  const appInfo = await settingsService.getAppInfo();
  console.log('应用名称:', appInfo.appName);
  console.log('版本:', appInfo.version);
  console.log('构建号:', appInfo.buildNumber);
} catch (error) {
  console.error('获取失败:', error.message);
}
```

### 检查更新

```typescript
const hasUpdate = await settingsService.checkForUpdates('1.0.0');
if (hasUpdate) {
  console.log('有新版本可用');
}
```

---

## 5. 备份服务（BackupService）

### 初始化

```typescript
import { BackupService } from '../services/BackupService';

const backupService = new BackupService(getContext(this));
```

### 创建备份

```typescript
try {
  const backup = await backupService.createBackup();
  console.log('备份ID:', backup.backupId);
  console.log('备份大小:', backup.fileSize);
  console.log('下载链接:', backup.downloadUrl);
  console.log('过期时间:', backup.expiresAt);
} catch (error) {
  console.error('创建备份失败:', error.message);
}
```

### 获取备份列表

```typescript
try {
  const response = await backupService.getBackupList();
  console.log('备份列表:', response.backups);
  
  response.backups.forEach(backup => {
    console.log('备份ID:', backup.backupId);
    console.log('备份时间:', backupService.formatBackupTime(backup.backupTime));
    console.log('文件大小:', backupService.formatFileSize(backup.fileSize));
  });
} catch (error) {
  console.error('获取备份列表失败:', error.message);
}
```

### 恢复备份

```typescript
try {
  const result = await backupService.restoreBackup('backup-uuid');
  console.log('恢复成功:', result.message);
  console.log('恢复日记数:', result.restoredDiaries);
  console.log('恢复照片数:', result.restoredPhotos);
} catch (error) {
  console.error('恢复备份失败:', error.message);
}
```

### 删除备份

```typescript
try {
  await backupService.deleteBackup('backup-uuid');
  console.log('删除成功');
} catch (error) {
  console.error('删除失败:', error.message);
}
```

---

## 错误处理

所有服务方法都会在出错时抛出异常，建议使用 try-catch 进行错误处理：

```typescript
try {
  const response = await diaryService.getDiaryList();
  // 处理成功响应
} catch (error) {
  // 处理错误
  console.error('请求失败:', error.message);
  
  // 根据错误类型处理
  if (error.message.includes('未授权')) {
    // Token 过期，重新登录
    await authService.refreshToken();
  }
}
```

---

## Token 管理

### 自动携带 Token

所有 API 请求都会自动携带 Token，无需手动设置。

### 刷新 Token

```typescript
try {
  const response = await authService.refreshToken();
  console.log('新Token:', response.token);
  console.log('过期时间:', response.tokenExpireAt);
} catch (error) {
  // Token 刷新失败，需要重新登录
  console.error('刷新Token失败:', error.message);
}
```

### Token 过期处理

建议在应用启动时或 Token 即将过期时自动刷新：

```typescript
// 检查 Token 是否快过期（例如还剩1小时）
const tokenExpireAt = await getTokenExpireTime();
const now = Date.now();
const oneHour = 60 * 60 * 1000;

if (tokenExpireAt - now < oneHour) {
  // 刷新 Token
  await authService.refreshToken();
}
```

---

## 完整使用示例

### 登录流程

```typescript
// 1. 初始化服务
const authService = new AuthService(getContext(this));
await authService.init();

// 2. 检查是否已登录
if (authService.isLoggedIn()) {
  // 已登录，刷新 Token
  try {
    await authService.refreshToken();
  } catch (error) {
    // 刷新失败，需要重新登录
    await showLoginPage();
  }
} else {
  // 未登录，显示登录页面
  await showLoginPage();
}
```

### 创建日记流程

```typescript
const diaryService = new DiaryService(getContext(this));

// 1. 创建日记
const diary = await diaryService.createDiary(
  '今天的心情',
  '今天天气很好，心情也很好！',
  'happy' as MoodType,
  ['生活', '心情']
);

// 2. 获取更新后的列表
const list = await diaryService.getDiaryList({ page: 1, pageSize: 20 });
console.log('最新日记列表:', list.items);
```

### 照片上传流程

```typescript
const photoService = new PhotoService(getContext(this));

// 1. 选择照片
const photoUris = await photoService.selectPhotos(9);

// 2. 上传照片
const result = await photoService.batchUploadPhotos(photoUris);

// 3. 显示结果
console.log(`上传完成: ${result.successCount}/${result.totalCount}`);

// 4. 刷新照片列表
const list = await photoService.getPhotoList({ page: 1, pageSize: 30 });
```

---

## 注意事项

### 1. 网络权限

确保在 `module.json5` 中添加了网络权限：

```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```

### 2. HTTPS 要求

生产环境必须使用 HTTPS 协议。

### 3. 错误处理

所有 API 调用都应该添加错误处理逻辑。

### 4. Token 安全

Token 存储在应用的私有存储空间，不会被其他应用访问。

### 5. 文件上传大小限制

单个文件最大 10MB，请在前端做好文件大小检查。

---

## 常见问题

### Q1: 如何修改后端 API 地址？

修改 `HttpClient.ets` 中的 `HttpConfig.BASE_URL`。

### Q2: Token 存储在哪里？

Token 存储在应用的 Preferences 中，自动加密保存。

### Q3: 如何处理网络超时？

可以修改 `HttpConfig.TIMEOUT` 调整超时时间（单位：毫秒）。

### Q4: 支持离线模式吗？

当前版本不支持离线模式，所有数据都需要从服务器获取。如需离线支持，可以结合本地数据库实现缓存。

### Q5: 如何调试 API 请求？

可以在 HttpClient 中查看日志输出，所有请求和响应都会记录到日志中。

---

## 技术支持

如有问题，请查看：
- `API_REQUIREMENTS.md` - 后端 API 接口文档
- `FRONTEND_API_GUIDE.md` - 前端 API 详细文档

---

**文档版本**: v1.0.0  
**最后更新**: 2024-10-24  
**维护者**: 开发团队

