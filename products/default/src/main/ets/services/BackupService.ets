import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpClient } from '../utils/HttpClient';
import {
  BackupResponse,
  BackupListResponse,
  RestoreBackupResponse,
  SuccessResponse
} from '../models/ApiTypes';

const logger: Logger = new Logger();

/**
 * 备份服务类 - 对接后端 API
 */
export class BackupService {
  private httpClient: HttpClient;

  constructor(context: Context) {
    this.httpClient = HttpClient.getInstance(context);
  }

  /**
   * 创建备份
   */
  public async createBackup(): Promise<BackupResponse> {
    try {
      const response = await this.httpClient.post<BackupResponse>('/backup');
      logger.info('BackupService', `Backup created: ${response.data.backupId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('BackupService', `Failed to create backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * 获取备份列表
   */
  public async getBackupList(): Promise<BackupListResponse> {
    try {
      const response = await this.httpClient.get<BackupListResponse>('/backup');
      logger.info('BackupService', `Got ${response.data.backups.length} backups`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('BackupService', `Failed to get backup list: ${error.message}`);
      throw error;
    }
  }

  /**
   * 恢复备份
   */
  public async restoreBackup(backupId: string): Promise<RestoreBackupResponse> {
    try {
      const response = await this.httpClient.post<RestoreBackupResponse>(`/backup/${backupId}/restore`);
      logger.info('BackupService', `Backup restored: ${backupId}`);
      logger.info('BackupService', `Restored ${response.data.restoredDiaries} diaries and ${response.data.restoredPhotos} photos`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('BackupService', `Failed to restore backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * 删除备份
   */
  public async deleteBackup(backupId: string): Promise<boolean> {
    try {
      const response = await this.httpClient.delete<SuccessResponse>(`/backup/${backupId}`);
      logger.info('BackupService', `Backup deleted: ${backupId}`);
      return response.data.success;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('BackupService', `Failed to delete backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * 下载备份文件
   */
  public async downloadBackup(backupId: string, downloadUrl: string): Promise<string> {
    try {
      // 注意：这里需要根据实际需求实现文件下载逻辑
      // 可以使用 HttpClient 下载文件到本地
      logger.info('BackupService', `Downloading backup: ${backupId} from ${downloadUrl}`);
      
      // TODO: 实现文件下载逻辑
      // 返回本地文件路径
      return downloadUrl;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('BackupService', `Failed to download backup: ${error.message}`);
      throw error;
    }
  }

  /**
   * 检查备份是否过期
   */
  public isBackupExpired(expiresAt: number): boolean {
    return Date.now() > expiresAt;
  }

  /**
   * 获取备份文件大小（格式化）
   */
  public formatFileSize(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B`;
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(2)} KB`;
    } else if (bytes < 1024 * 1024 * 1024) {
      return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
    } else {
      return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
    }
  }

  /**
   * 格式化备份时间
   */
  public formatBackupTime(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }
}

