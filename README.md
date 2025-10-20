# 我的秘密空间 - 鸿蒙应用

一个安全的私密日记和相册应用，支持密码/指纹登录保护。

## 功能特性

### 🔐 安全登录
- 6位数字密码保护
- 指纹识别快速登录
- 首次启动引导设置密码

### 📔 私密日记
- 创建和编辑日记
- 心情记录（开心、难过、平静、兴奋、疲惫）
- 自定义标签管理
- 日记列表浏览和搜索
- 长按删除日记

### 📷 私密相册
- 从相册选择照片
- 照片网格展示
- 全屏查看和缩放
- 左右滑动切换照片
- 长按删除照片

### 🎨 设计特色
- 简约现代的UI风格
- 流畅的动画效果
- 卡片式设计
- 响应式布局
- 优雅的交互体验

## 技术栈

- **开发框架**: HarmonyOS NEXT API 12
- **开发语言**: ArkTS
- **UI框架**: ArkUI
- **数据存储**: 
  - 关系型数据库 (relationalStore)
  - 用户偏好设置 (preferences)
- **安全特性**: 
  - 生物识别认证 (UserAuthenticationKit)
  - 密码加密存储

## 项目结构

```
treehole/
├── products/default/src/main/
│   ├── ets/
│   │   ├── models/              # 数据模型
│   │   │   ├── DiaryModel.ets
│   │   │   ├── PhotoModel.ets
│   │   │   └── UserModel.ets
│   │   ├── database/            # 数据库管理
│   │   │   └── DatabaseHelper.ets
│   │   ├── services/            # 业务服务
│   │   │   ├── AuthService.ets
│   │   │   ├── DiaryService.ets
│   │   │   └── PhotoService.ets
│   │   ├── pages/               # 页面
│   │   │   ├── LoginPage.ets
│   │   │   ├── MainPage.ets
│   │   │   ├── DiaryListPage.ets
│   │   │   ├── DiaryEditPage.ets
│   │   │   ├── PhotoGridPage.ets
│   │   │   ├── PhotoDetailPage.ets
│   │   │   └── SettingsPage.ets
│   │   ├── components/          # 组件
│   │   │   ├── MoodSelector.ets
│   │   │   └── TagManager.ets
│   │   ├── theme/               # 主题
│   │   │   └── AppTheme.ets
│   │   └── defaultability/
│   │       └── DefaultAbility.ets
│   └── resources/               # 资源文件
└── common/                      # 公共模块
    └── src/main/ets/utils/
        └── Logger.ets

```

## 开发指南

### 环境要求
- DevEco Studio NEXT
- HarmonyOS SDK API 12+
- 支持指纹识别的设备（可选）

### 运行项目
1. 使用 DevEco Studio 打开项目
2. 配置鸿蒙模拟器或连接真机
3. 点击运行按钮启动应用

### 首次使用
1. 应用启动后会提示设置6位数字密码
2. 输入密码两次进行确认
3. 设置完成后可以在设置中开启指纹识别

## 权限说明

应用需要以下权限：
- `ohos.permission.READ_MEDIA` - 读取媒体文件以添加照片
- `ohos.permission.WRITE_MEDIA` - 保存照片到应用目录
- `ohos.permission.ACCESS_BIOMETRIC` - 使用指纹识别功能

## 数据安全

- 密码采用加密存储
- 照片保存在应用沙箱目录，其他应用无法访问
- 日记数据使用关系型数据库本地存储
- 所有数据仅存储在本地，不会上传到云端

## 功能演示

### 登录界面
- 首次使用设置密码
- 支持数字键盘输入
- 指纹识别快捷登录

### 日记功能
- 创建日记：记录标题、内容、心情和标签
- 浏览日记：卡片式列表展示
- 编辑日记：点击卡片进入编辑
- 删除日记：长按卡片删除

### 相册功能
- 添加照片：从系统相册选择
- 浏览照片：3列网格展示
- 查看照片：全屏查看，支持缩放和滑动
- 删除照片：长按网格或在详情页删除

### 设置功能
- 修改密码
- 指纹识别开关
- 关于应用信息

## 后续优化方向

- [ ] 支持日记导出和备份
- [ ] 添加日记分类功能
- [ ] 支持图文混排日记
- [ ] 添加搜索功能
- [ ] 支持主题切换（深色模式）
- [ ] 数据加密存储增强
- [ ] 添加回收站功能
- [ ] 支持云端同步（可选）

## 版本信息

- 当前版本: 1.0.0
- 最低支持API: 12
- 目标设备: Phone

## 开源协议

MIT License

---

**注意**: 本应用注重用户隐私保护，所有数据仅在本地存储，请妥善保管您的密码。

