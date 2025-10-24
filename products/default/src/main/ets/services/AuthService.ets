import { preferences } from '@kit.ArkData';
import { userAuth } from '@kit.UserAuthenticationKit';
import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpClient } from '../utils/HttpClient';
import {
  RegisterRequest,
  RegisterResponse,
  LoginRequest,
  LoginResponse,
  RefreshTokenResponse,
  ChangePasswordRequest,
  BiometricSettingRequest,
  BiometricSettingResponse,
  SuccessResponse
} from '../models/ApiTypes';

const logger: Logger = new Logger();
const PREFERENCES_NAME = 'auth_preferences';
const KEY_PASSWORD_HASH = 'password_hash';
const KEY_BIOMETRIC_ENABLED = 'biometric_enabled';
const KEY_HAS_SET_PASSWORD = 'has_set_password';
const KEY_DEVICE_ID = 'device_id';

/**
 * 认证服务类 - 对接后端 API
 */
export class AuthService {
  private context: Context;
  private prefs: preferences.Preferences | null = null;
  private httpClient: HttpClient;

  constructor(context: Context) {
    this.context = context;
    this.httpClient = HttpClient.getInstance(context);
  }

  /**
   * 初始化
   */
  public async init(): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(this.context, PREFERENCES_NAME);
      await this.httpClient.init();
      logger.info('AuthService', 'AuthService initialized');
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Failed to init AuthService: ${error.message}`);
      throw new Error(`Failed to init AuthService: ${error.message}`);
    }
  }

  /**
   * 获取或生成设备 ID
   */
  private async getDeviceId(): Promise<string> {
    if (!this.prefs) {
      await this.init();
    }

    let deviceId = await this.prefs!.get(KEY_DEVICE_ID, '') as string;
    if (!deviceId) {
      // 生成唯一设备 ID
      deviceId = `device_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      await this.prefs!.put(KEY_DEVICE_ID, deviceId);
      await this.prefs!.flush();
    }

    return deviceId;
  }

  /**
   * 用户注册/设置密码
   */
  public async register(password: string, confirmPassword: string): Promise<RegisterResponse> {
    try {
      const deviceId = await this.getDeviceId();
      const request: RegisterRequest = {
        password,
        confirmPassword,
        deviceId
      };

      const response = await this.httpClient.post<RegisterResponse>('/auth/register', request);
      
      // 保存 token 和用户信息
      await this.httpClient.setToken(response.data.token);
      await this.httpClient.setUserId(response.data.userId);
      await this.prefs!.put(KEY_HAS_SET_PASSWORD, true);
      await this.prefs!.flush();

      logger.info('AuthService', 'Register successful');
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Register failed: ${error.message}`);
      throw new Error(`Register failed: ${error.message}`);
    }
  }

  /**
   * 密码登录
   */
  public async login(password: string): Promise<LoginResponse> {
    try {
      const deviceId = await this.getDeviceId();
      const request: LoginRequest = {
        password,
        deviceId
      };

      const response = await this.httpClient.post<LoginResponse>('/auth/login', request);
      
      // 保存 token 和用户信息
      await this.httpClient.setToken(response.data.token);
      await this.httpClient.setUserId(response.data.userId);
      await this.prefs!.put(KEY_BIOMETRIC_ENABLED, response.data.biometricEnabled);
      await this.prefs!.flush();

      logger.info('AuthService', 'Login successful');
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Login failed: ${error.message}`);
      throw new Error(`Login failed: ${error.message}`);
    }
  }

  /**
   * 刷新 Token
   */
  public async refreshToken(): Promise<RefreshTokenResponse> {
    try {
      const response = await this.httpClient.post<RefreshTokenResponse>('/auth/refresh');
      
      // 更新 token
      await this.httpClient.setToken(response.data.token);

      logger.info('AuthService', 'Token refreshed');
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Refresh token failed: ${error.message}`);
      throw new Error(`Refresh token failed: ${error.message}`);
    }
  }

  /**
   * 修改密码
   */
  public async changePassword(oldPassword: string, newPassword: string, confirmPassword: string): Promise<boolean> {
    try {
      const request: ChangePasswordRequest = {
        oldPassword,
        newPassword,
        confirmPassword
      };

      const response = await this.httpClient.put<SuccessResponse>('/auth/password', request);
      
      logger.info('AuthService', 'Password changed successfully');
      return response.data.success;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Change password failed: ${error.message}`);
      throw new Error(`Change password failed: ${error.message}`);
    }
  }

  /**
   * 设置生物识别开关
   */
  public async setBiometricEnabled(enabled: boolean, deviceBiometricId?: string): Promise<BiometricSettingResponse> {
    try {
      const request: BiometricSettingRequest = {
        enabled,
        deviceBiometricId
      };

      const response = await this.httpClient.put<BiometricSettingResponse>('/auth/biometric', request);
      
      // 保存本地设置
      await this.prefs!.put(KEY_BIOMETRIC_ENABLED, response.data.biometricEnabled);
      await this.prefs!.flush();

      logger.info('AuthService', `Biometric set to: ${enabled}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Set biometric failed: ${error.message}`);
      throw new Error(`Set biometric failed: ${error.message}`);
    }
  }

  /**
   * 登出
   */
  public async logout(): Promise<void> {
    try {
      await this.httpClient.clearToken();
      logger.info('AuthService', 'Logout successful');
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Logout failed: ${error.message}`);
    }
  }

  /**
   * 检查是否已设置密码（本地检查）
   */
  public async hasSetPassword(): Promise<boolean> {
    if (!this.prefs) {
      await this.init();
    }
    return await this.prefs!.get(KEY_HAS_SET_PASSWORD, false) as boolean;
  }

  /**
   * 检查是否启用生物识别（本地检查）
   */
  public async isBiometricEnabled(): Promise<boolean> {
    if (!this.prefs) {
      await this.init();
    }
    return await this.prefs!.get(KEY_BIOMETRIC_ENABLED, false) as boolean;
  }

  /**
   * 检查设备是否支持生物识别
   */
  public async checkBiometricSupport(): Promise<boolean> {
    try {
      const authParam: userAuth.AuthParam = {
        challenge: new Uint8Array([1, 2, 3, 4, 5]),
        authType: [userAuth.UserAuthType.FINGERPRINT],
        authTrustLevel: userAuth.AuthTrustLevel.ATL1
      };

      const widgetParam: userAuth.WidgetParam = {
        title: '检查指纹支持'
      };

      const userAuthInstance = userAuth.getUserAuthInstance(authParam, widgetParam);
      if (userAuthInstance) {
        userAuthInstance.cancel();
        return true;
      }
      return false;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Biometric check failed: ${error.message}`);
      return false;
    }
  }

  /**
   * 执行生物识别认证
   */
  public async authenticateWithBiometric(): Promise<boolean> {
    try {
      const authParam: userAuth.AuthParam = {
        challenge: new Uint8Array([1, 2, 3, 4, 5]),
        authType: [userAuth.UserAuthType.FINGERPRINT],
        authTrustLevel: userAuth.AuthTrustLevel.ATL1
      };

      const widgetParam: userAuth.WidgetParam = {
        title: '指纹验证'
      };

      const userAuthInstance = userAuth.getUserAuthInstance(authParam, widgetParam);

      return new Promise((resolve) => {
        userAuthInstance.on('result', {
          onResult(result) {
            logger.info('AuthService', `Biometric auth result: ${result.result}`);
            resolve(result.result === userAuth.UserAuthResultCode.SUCCESS);
          }
        });

        userAuthInstance.start();
      });
    } catch (err) {
      logger.error('AuthService', `Biometric auth failed: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 获取当前 Token
   */
  public getToken(): string {
    return this.httpClient.getToken();
  }

  /**
   * 检查是否已登录
   */
  public isLoggedIn(): boolean {
    return this.httpClient.getToken() !== '';
  }

  /**
   * 验证密码（兼容方法，实际调用 login）
   */
  public async verifyPassword(password: string): Promise<boolean> {
    try {
      await this.login(password);
      return true;
    } catch (err) {
      logger.error('AuthService', `Verify password failed: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 设置密码（兼容方法，实际调用 register）
   */
  public async setPassword(password: string): Promise<void> {
    try {
      await this.register(password, password);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('AuthService', `Set password failed: ${error.message}`);
      throw new Error(`Set password failed: ${error.message}`);
    }
  }
}
