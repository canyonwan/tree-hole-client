import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpClient } from '../utils/HttpClient';
import {
  UserSettingsResponse,
  UpdateSettingsRequest,
  AppInfoResponse,
  SuccessResponse,
  NotificationSettings,
  PrivacySettings
} from '../models/ApiTypes';

const logger: Logger = new Logger();

/**
 * 设置服务类 - 对接后端 API
 */
export class SettingsService {
  private httpClient: HttpClient;

  constructor(context: Context) {
    this.httpClient = HttpClient.getInstance(context);
  }

  /**
   * 获取用户设置
   */
  public async getUserSettings(): Promise<UserSettingsResponse> {
    try {
      const response = await this.httpClient.get<UserSettingsResponse>('/settings');
      logger.info('SettingsService', 'Got user settings');
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to get user settings: ${error.message}`);
      throw error;
    }
  }

  /**
   * 更新用户设置
   */
  public async updateUserSettings(settings: UpdateSettingsRequest): Promise<boolean> {
    try {
      const response = await this.httpClient.put<SuccessResponse>('/settings', settings);
      logger.info('SettingsService', 'User settings updated');
      return response.data.success;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to update user settings: ${error.message}`);
      throw error;
    }
  }

  /**
   * 更新主题设置
   */
  public async updateTheme(theme: 'auto' | 'light' | 'dark'): Promise<boolean> {
    try {
      return await this.updateUserSettings({ theme });
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to update theme: ${error.message}`);
      throw error;
    }
  }

  /**
   * 更新自动备份设置
   */
  public async updateAutoBackup(autoBackup: boolean, backupFrequency?: 'daily' | 'weekly' | 'monthly'): Promise<boolean> {
    try {
      const settings: UpdateSettingsRequest = {
        autoBackup
      };
      
      if (backupFrequency) {
        settings.backupFrequency = backupFrequency;
      }

      return await this.updateUserSettings(settings);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to update auto backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * 更新通知设置
   */
  public async updateNotifications(notifications: NotificationSettings): Promise<boolean> {
    try {
      return await this.updateUserSettings({ notifications });
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to update notifications: ${error.message}`);
      throw error;
    }
  }

  /**
   * 更新隐私设置
   */
  public async updatePrivacy(privacy: PrivacySettings): Promise<boolean> {
    try {
      return await this.updateUserSettings({ privacy });
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to update privacy: ${error.message}`);
      throw error;
    }
  }

  /**
   * 获取应用信息
   */
  public async getAppInfo(): Promise<AppInfoResponse> {
    try {
      const response = await this.httpClient.get<AppInfoResponse>('/about');
      logger.info('SettingsService', 'Got app info');
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to get app info: ${error.message}`);
      throw error;
    }
  }

  /**
   * 检查是否有新版本
   */
  public async checkForUpdates(currentVersion: string): Promise<boolean> {
    try {
      const appInfo = await this.getAppInfo();
      
      // 简单的版本比较逻辑
      const current = this.parseVersion(currentVersion);
      const latest = this.parseVersion(appInfo.version);
      
      return latest > current;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('SettingsService', `Failed to check for updates: ${error.message}`);
      return false;
    }
  }

  /**
   * 解析版本号
   */
  private parseVersion(version: string): number {
    try {
      const parts = version.split('.').map(Number);
      return parts[0] * 10000 + parts[1] * 100 + parts[2];
    } catch {
      return 0;
    }
  }
}

