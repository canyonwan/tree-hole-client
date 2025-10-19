import { preferences } from '@kit.ArkData';
import { userAuth } from '@kit.UserAuthenticationKit';
import { Logger } from '../../../common/src/main/ets/utils/Logger';
import { util } from '@kit.ArkTS';

const logger = new Logger();
const PREFERENCES_NAME = 'auth_preferences';
const KEY_PASSWORD_HASH = 'password_hash';
const KEY_BIOMETRIC_ENABLED = 'biometric_enabled';
const KEY_HAS_SET_PASSWORD = 'has_set_password';

/**
 * 认证服务类
 */
export class AuthService {
  private context: Context;
  private prefs: preferences.Preferences | null = null;

  constructor(context: Context) {
    this.context = context;
  }

  /**
   * 初始化
   */
  public async init(): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(this.context, PREFERENCES_NAME);
      logger.info('AuthService', 'AuthService initialized');
    } catch (err) {
      logger.error('AuthService', `Failed to init AuthService: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 检查是否已设置密码
   */
  public async hasSetPassword(): Promise<boolean> {
    if (!this.prefs) {
      await this.init();
    }
    return await this.prefs!.get(KEY_HAS_SET_PASSWORD, false) as boolean;
  }

  /**
   * 设置密码
   */
  public async setPassword(password: string): Promise<void> {
    if (!this.prefs) {
      await this.init();
    }

    try {
      const hash = this.hashPassword(password);
      await this.prefs!.put(KEY_PASSWORD_HASH, hash);
      await this.prefs!.put(KEY_HAS_SET_PASSWORD, true);
      await this.prefs!.flush();
      logger.info('AuthService', 'Password set successfully');
    } catch (err) {
      logger.error('AuthService', `Failed to set password: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 验证密码
   */
  public async verifyPassword(password: string): Promise<boolean> {
    if (!this.prefs) {
      await this.init();
    }

    try {
      const storedHash = await this.prefs!.get(KEY_PASSWORD_HASH, '') as string;
      const inputHash = this.hashPassword(password);
      return storedHash === inputHash;
    } catch (err) {
      logger.error('AuthService', `Failed to verify password: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 修改密码
   */
  public async changePassword(oldPassword: string, newPassword: string): Promise<boolean> {
    const isValid = await this.verifyPassword(oldPassword);
    if (!isValid) {
      return false;
    }

    await this.setPassword(newPassword);
    return true;
  }

  /**
   * 检查是否启用生物识别
   */
  public async isBiometricEnabled(): Promise<boolean> {
    if (!this.prefs) {
      await this.init();
    }
    return await this.prefs!.get(KEY_BIOMETRIC_ENABLED, false) as boolean;
  }

  /**
   * 设置生物识别开关
   */
  public async setBiometricEnabled(enabled: boolean): Promise<void> {
    if (!this.prefs) {
      await this.init();
    }

    try {
      await this.prefs!.put(KEY_BIOMETRIC_ENABLED, enabled);
      await this.prefs!.flush();
      logger.info('AuthService', `Biometric set to: ${enabled}`);
    } catch (err) {
      logger.error('AuthService', `Failed to set biometric: ${JSON.stringify(err)}`);
      throw err;
    }
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
        title: '指纹验证'
      };

      const userAuthInstance = userAuth.getUserAuthInstance(authParam, widgetParam);
      const availableStatus = userAuthInstance.checkAuthCapability();

      return availableStatus === userAuth.UserAuthResultCode.SUCCESS;
    } catch (err) {
      logger.error('AuthService', `Biometric check failed: ${JSON.stringify(err)}`);
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
   * 简单的密码哈希函数
   */
  private hashPassword(password: string): string {
    const textEncoder = new util.TextEncoder();
    const data = textEncoder.encodeInto(password);
    const md5 = util.generateRandomUUID(); // 简化处理，实际应用中应使用更安全的哈希算法
    // 这里使用简单的Base64编码模拟哈希
    return util.Base64Helper.encodeToStringSync(data);
  }
}

