import { DatabaseHelper } from '../database/DatabaseHelper';
import { PhotoModel } from '../models/PhotoModel';
import { Logger } from '@ohos/common';
import { fileIo } from '@kit.CoreFileKit';
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

const logger: Logger = new Logger();

/**
 * 相册业务服务类
 */
export class PhotoService {
  private dbHelper: DatabaseHelper;
  private context: Context;

  constructor(context: Context) {
    this.context = context;
    this.dbHelper = DatabaseHelper.getInstance(context);
  }

  /**
   * 选择图片
   */
  public async selectPhotos(): Promise<string[]> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 9;

      const photoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      return photoSelectResult.photoUris;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to select photos: ${error.message}`);
      throw new Error(`Failed to select photos: ${error.message}`);
    }
  }

  /**
   * 保存照片到应用目录
   */
  public async savePhoto(sourceUri: string, description: string = ''): Promise<number> {
    try {
      // 获取应用私有目录
      const filesDir = this.context.filesDir;
      const photoDir = `${filesDir}/photos`;

      // 创建photos目录（如果不存在）
      if (!fileIo.accessSync(photoDir)) {
        fileIo.mkdirSync(photoDir);
      }

      // 生成唯一文件名
      const timestamp = Date.now();
      const fileName = `photo_${timestamp}.jpg`;
      const destPath = `${photoDir}/${fileName}`;

      // 复制文件到应用目录
      fileIo.copyFileSync(sourceUri, destPath);

      // 保存到数据库
      const photo: PhotoModel = {
        filePath: destPath,
        description,
        createTime: timestamp
      };

      const id = await this.dbHelper.insertPhoto(photo);
      logger.info('PhotoService', `Photo saved with id: ${id}`);
      return id;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to save photo: ${error.message}`);
      throw new Error(`Failed to save photo: ${error.message}`);
    }
  }

  /**
   * 删除照片
   */
  public async deletePhoto(id: number, filePath: string): Promise<void> {
    try {
      // 删除文件
      try {
        if (fileIo.accessSync(filePath)) {
          fileIo.unlinkSync(filePath);
        }
      } catch (err) {
        logger.warn('PhotoService', `File not found or already deleted: ${filePath}`);
      }

      // 从数据库删除
      await this.dbHelper.deletePhoto(id);
      logger.info('PhotoService', `Photo deleted: ${id}`);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to delete photo: ${error.message}`);
      throw new Error(`Failed to delete photo: ${error.message}`);
    }
  }

  /**
   * 获取所有照片
   */
  public async getAllPhotos(): Promise<PhotoModel[]> {
    try {
      return await this.dbHelper.queryAllPhotos();
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to get photos: ${error.message}`);
      throw new Error(`Failed to get photos: ${error.message}`);
    }
  }
}

