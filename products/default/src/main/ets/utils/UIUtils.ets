/**
 * UI工具类
 * 提供Toast和Dialog的封装，替代废弃的promptAction API
 */
import { promptAction } from '@kit.ArkUI';
import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';

const logger: Logger = new Logger();

/**
 * Toast配置选项
 */
export interface ToastOptions {
  message: string;
  duration?: number;
  bottom?: string | number;
}

/**
 * Dialog按钮配置
 */
export interface DialogButton {
  text: string;
  color: string;
}

/**
 * Dialog配置选项
 */
export interface DialogOptions {
  title?: string;
  message: string;
  buttons?: DialogButton[];
  onConfirm?: () => void;
  onCancel?: () => void;
}

/**
 * Dialog结果
 */
export interface DialogResult {
  index: number;
}

/**
 * UI工具类
 */
export class UIUtils {
  /**
   * 显示Toast提示
   * 替代 promptAction.showToast
   */
  static showToast(options: ToastOptions): void {
    try {
      promptAction.showToast({
        message: options.message,
        duration: options.duration || 2000,
        bottom: options.bottom || '50vp'
      });
    } catch (err) {
      const error = err as BusinessError;
      logger.error('UIUtils', `Show toast failed: ${error.message}`);
    }
  }

  /**
   * 显示确认对话框
   * 替代 promptAction.showDialog，返回Promise以便使用async/await
   */
  static showConfirmDialog(options: DialogOptions): Promise<DialogResult> {
    return new Promise((resolve, reject) => {
      try {
        promptAction.showDialog({
          title: options.title || '提示',
          message: options.message,
          buttons: options.buttons || [
            { text: '取消', color: '#999999' },
            { text: '确定', color: '#007DFF' }
          ]
        }).then((result: promptAction.ShowDialogSuccessResponse) => {
          resolve({ index: result.index });
        }).catch((err: Error) => {
          reject(err);
        });
      } catch (err) {
        const error = err as BusinessError;
        logger.error('UIUtils', `Show dialog failed: ${error.message}`);
        reject(error);
      }
    });
  }

  /**
   * 显示信息对话框（仅确定按钮）
   */
  static showInfoDialog(title: string, message: string): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        promptAction.showDialog({
          title: title,
          message: message,
          buttons: [{ text: '确定', color: '#007DFF' }]
        }).then(() => {
          resolve();
        }).catch((err: Error) => {
          reject(err);
        });
      } catch (err) {
        const error = err as BusinessError;
        logger.error('UIUtils', `Show info dialog failed: ${error.message}`);
        reject(error);
      }
    });
  }

  /**
   * 显示成功提示
   */
  static showSuccess(message: string): void {
    UIUtils.showToast({ message: message, duration: 2000 });
  }

  /**
   * 显示错误提示
   */
  static showError(message: string): void {
    UIUtils.showToast({ message: message, duration: 2000 });
  }

  /**
   * 显示加载提示
   */
  static showLoading(message: string = '加载中...'): void {
    UIUtils.showToast({ message: message, duration: 2000 });
  }
}

