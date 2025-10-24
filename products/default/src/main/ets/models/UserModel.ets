/**
 * 用户配置模型（后端返回）
 */
export interface UserModel {
  userId: string;
  deviceId: string;
  passwordHash?: string;
  biometricEnabled: boolean;
  createdAt: number;
  updatedAt: number;
  lastLoginAt: number;
}

/**
 * 用户偏好设置（本地）
 */
export interface UserPreferences {
  hasSetPassword: boolean;
  biometricEnabled: boolean;
  userId?: string;
  token?: string;
}

