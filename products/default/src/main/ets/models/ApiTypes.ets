/**
 * API 通用类型定义
 */

// ==================== 认证相关 ====================

/**
 * 注册请求
 */
export interface RegisterRequest {
  password: string;
  confirmPassword: string;
  deviceId: string;
}

/**
 * 注册响应
 */
export interface RegisterResponse {
  userId: string;
  token: string;
  createdAt: number;
}

/**
 * 登录请求
 */
export interface LoginRequest {
  password: string;
  deviceId: string;
}

/**
 * 登录响应
 */
export interface LoginResponse {
  userId: string;
  token: string;
  tokenExpireAt: number;
  biometricEnabled: boolean;
}

/**
 * 刷新 Token 响应
 */
export interface RefreshTokenResponse {
  token: string;
  tokenExpireAt: number;
}

/**
 * 修改密码请求
 */
export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
  confirmPassword: string;
}

/**
 * 生物识别设置请求
 */
export interface BiometricSettingRequest {
  enabled: boolean;
  deviceBiometricId?: string;
}

/**
 * 生物识别设置响应
 */
export interface BiometricSettingResponse {
  success: boolean;
  biometricEnabled: boolean;
}

// ==================== 日记相关 ====================

/**
 * 心情类型
 */
export type MoodType = 'happy' | 'sad' | 'calm' | 'excited' | 'tired';

/**
 * 创建日记请求
 */
export interface CreateDiaryRequest {
  title?: string;
  content: string;
  mood: MoodType;
  tags: string[];
  createdDate?: number;
}

/**
 * 日记响应
 */
export interface DiaryResponse {
  diaryId: string;
  userId: string;
  title?: string;
  content: string;
  contentPreview?: string;
  mood: MoodType;
  tags: string[];
  createdAt: number;
  updatedAt: number;
}

/**
 * 更新日记请求
 */
export interface UpdateDiaryRequest {
  title?: string;
  content: string;
  mood: MoodType;
  tags: string[];
}

/**
 * 日记列表查询参数
 */
export interface DiaryListParams {
  page?: number;
  pageSize?: number;
  keyword?: string;
  mood?: MoodType;
  tags?: string;
  startDate?: number;
  endDate?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

/**
 * 批量删除请求
 */
export interface BatchDeleteRequest {
  diaryIds?: string[];
  photoIds?: string[];
}

/**
 * 批量删除响应
 */
export interface BatchDeleteResponse {
  success: boolean;
  deletedCount: number;
  message: string;
}

/**
 * 标签项
 */
export interface TagItem {
  name: string;
  count: number;
}

/**
 * 标签响应
 */
export interface TagsResponse {
  tags: TagItem[];
}

/**
 * 心情统计项
 */
export interface MoodStatItem {
  mood: MoodType;
  count: number;
  percentage: number;
}

/**
 * 心情统计响应
 */
export interface MoodStatsResponse {
  stats: MoodStatItem[];
  totalDiaries: number;
}

// ==================== 照片相关 ====================

/**
 * 照片 EXIF 信息
 */
/**
 * 照片位置信息
 */
export interface PhotoLocation {
  latitude: number;
  longitude: number;
}

/**
 * 照片 EXIF 信息
 */
export interface PhotoExif {
  camera?: string;
  iso?: string;
  aperture?: string;
  shutterSpeed?: string;
  focalLength?: string;
  location?: PhotoLocation;
}

/**
 * 照片响应
 */
export interface PhotoResponse {
  photoId: string;
  url: string;
  thumbnailUrl: string;
  description?: string;
  fileSize: number;
  width: number;
  height: number;
  format: string;
  exif?: PhotoExif;
  takenAt?: number;
  uploadedAt: number;
}

/**
 * 批量上传照片项
 */
export interface BatchUploadPhotoItem {
  photoId: string;
  url: string;
  thumbnailUrl: string;
}

/**
 * 批量上传照片响应
 */
export interface BatchUploadResponse {
  totalCount: number;
  successCount: number;
  failedCount: number;
  photos: Array<BatchUploadPhotoItem>;
}

/**
 * 照片列表查询参数
 */
export interface PhotoListParams {
  page?: number;
  pageSize?: number;
  startDate?: number;
  endDate?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

/**
 * 照片上传趋势项
 */
export interface PhotoUploadTrendItem {
  date: string;
  count: number;
}

/**
 * 照片统计响应
 */
export interface PhotoStatsResponse {
  totalPhotos: number;
  totalSize: number;
  formatsDistribution: Record<string, number>;
  uploadTrend: Array<PhotoUploadTrendItem>;
}

// ==================== 用户设置相关 ====================

/**
 * 通知设置
 */
export interface NotificationSettings {
  enabled: boolean;
  reminderTime: string;
}

/**
 * 隐私设置
 */
export interface PrivacySettings {
  dataEncryption: boolean;
  hidePreviewInTaskSwitcher: boolean;
}

/**
 * 用户设置响应
 */
export interface UserSettingsResponse {
  userId: string;
  biometricEnabled: boolean;
  theme: 'auto' | 'light' | 'dark';
  language: string;
  autoBackup: boolean;
  backupFrequency: 'daily' | 'weekly' | 'monthly';
  notifications: NotificationSettings;
  privacy: PrivacySettings;
}

/**
 * 更新用户设置请求
 */
export interface UpdateSettingsRequest {
  theme?: 'auto' | 'light' | 'dark';
  autoBackup?: boolean;
  backupFrequency?: 'daily' | 'weekly' | 'monthly';
  notifications?: NotificationSettings;
  privacy?: PrivacySettings;
}

/**
 * 应用信息响应
 */
export interface AppInfoResponse {
  appName: string;
  version: string;
  buildNumber: string;
  apiVersion: string;
  minSupportedVersion: string;
}

// ==================== 备份相关 ====================

/**
 * 备份项
 */
export interface BackupItem {
  backupId: string;
  backupTime: number;
  fileSize: number;
  downloadUrl: string;
  expiresAt: number;
}

/**
 * 备份响应
 */
export interface BackupResponse extends BackupItem {}

/**
 * 备份列表响应
 */
export interface BackupListResponse {
  backups: BackupItem[];
}

/**
 * 恢复备份响应
 */
export interface RestoreBackupResponse {
  success: boolean;
  restoredDiaries: number;
  restoredPhotos: number;
  message: string;
}

// ==================== 通用响应 ====================

/**
 * 成功响应
 */
export interface SuccessResponse {
  success: boolean;
  message: string;
}

