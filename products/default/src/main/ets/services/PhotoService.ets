import { DatabaseHelper } from '../database/DatabaseHelper';
import { PhotoModel } from '../models/PhotoModel';
import { Logger } from '../../../common/src/main/ets/utils/Logger';
import { fileIo, fs } from '@kit.CoreFileKit';
import { picker } from '@kit.CoreFileKit';

const logger = new Logger();

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
      photoSelectOptions.mimeType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 9;

      const photoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      return photoSelectResult.photoUris;
    } catch (err) {
      logger.error('PhotoService', `Failed to select photos: ${JSON.stringify(err)}`);
      throw err;
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
      try {
        await fs.access(photoDir);
      } catch {
        await fs.mkdir(photoDir);
      }

      // 生成唯一文件名
      const timestamp = Date.now();
      const fileName = `photo_${timestamp}.jpg`;
      const destPath = `${photoDir}/${fileName}`;

      // 复制文件到应用目录
      await fs.copyFile(sourceUri, destPath);

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
      logger.error('PhotoService', `Failed to save photo: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 删除照片
   */
  public async deletePhoto(id: number, filePath: string): Promise<void> {
    try {
      // 删除文件
      try {
        await fs.access(filePath);
        await fs.unlink(filePath);
      } catch (err) {
        logger.warn('PhotoService', `File not found or already deleted: ${filePath}`);
      }

      // 从数据库删除
      await this.dbHelper.deletePhoto(id);
      logger.info('PhotoService', `Photo deleted: ${id}`);
    } catch (err) {
      logger.error('PhotoService', `Failed to delete photo: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 获取所有照片
   */
  public async getAllPhotos(): Promise<PhotoModel[]> {
    try {
      return await this.dbHelper.queryAllPhotos();
    } catch (err) {
      logger.error('PhotoService', `Failed to get photos: ${JSON.stringify(err)}`);
      throw err;
    }
  }
}

