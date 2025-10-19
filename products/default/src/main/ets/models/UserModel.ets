/**
 * 用户配置模型
 */
export interface UserModel {
  passwordHash: string;
  useBiometric: boolean;
  lastLoginTime: number;
}

/**
 * 用户偏好设置
 */
export interface UserPreferences {
  hasSetPassword: boolean;
  biometricEnabled: boolean;
}

