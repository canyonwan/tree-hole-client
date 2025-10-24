import { Logger } from '@ohos/common';
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpClient, PageResponse } from '../utils/HttpClient';
import { PhotoModel } from '../models/PhotoModel';
import {
  PhotoResponse,
  BatchUploadResponse,
  BatchUploadPhotoItem,
  PhotoListParams,
  PhotoStatsResponse,
  BatchDeleteRequest,
  BatchDeleteResponse,
  SuccessResponse
} from '../models/ApiTypes';

const logger: Logger = new Logger();

/**
 * 相册业务服务类 - 对接后端 API
 */
export class PhotoService {
  private httpClient: HttpClient;
  private context: Context;

  constructor(context: Context) {
    this.context = context;
    this.httpClient = HttpClient.getInstance(context);
  }

  /**
   * 选择图片
   */
  public async selectPhotos(maxCount: number = 9): Promise<string[]> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = maxCount;

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
   * 上传单张照片
   */
  public async uploadPhoto(filePath: string, description?: string, takenAt?: number): Promise<PhotoResponse> {
    try {
      const extraData: Record<string, string> = {};
      if (description) {
        extraData.description = description;
      }
      if (takenAt) {
        extraData.takenAt = String(takenAt);
      }

      const response = await this.httpClient.uploadFile<PhotoResponse>('/photos', filePath, 'file', extraData);
      logger.info('PhotoService', `Photo uploaded: ${response.data.photoId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to upload photo: ${error.message}`);
      throw new Error(`Failed to upload photo: ${error.message}`);
    }
  }

  /**
   * 批量上传照片
   */
  public async batchUploadPhotos(filePaths: string[]): Promise<BatchUploadResponse> {
    try {
      // 注意：这里需要根据后端实际实现调整
      // 可能需要多次调用单张上传，或者使用特殊的批量上传接口
      const uploadPromises = filePaths.map(filePath => this.uploadPhoto(filePath));
      const results = await Promise.allSettled(uploadPromises);

      const successResults: PhotoResponse[] = [];
      let successCount = 0;
      let failedCount = 0;

      results.forEach(result => {
        if (result.status === 'fulfilled') {
          successResults.push(result.value);
          successCount++;
        } else {
          failedCount++;
          logger.error('PhotoService', `Upload failed: ${result.reason}`);
        }
      });

      const photoItems: BatchUploadPhotoItem[] = successResults.map((photo: PhotoResponse): BatchUploadPhotoItem => {
        const item: BatchUploadPhotoItem = {
          photoId: photo.photoId,
          url: photo.url,
          thumbnailUrl: photo.thumbnailUrl
        };
        return item;
      });

      const batchResponse: BatchUploadResponse = {
        totalCount: filePaths.length,
        successCount,
        failedCount,
        photos: photoItems
      };

      logger.info('PhotoService', `Batch upload: ${successCount}/${filePaths.length} succeeded`);
      return batchResponse;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to batch upload photos: ${error.message}`);
      throw new Error(`Failed to batch upload photos: ${error.message}`);
    }
  }

  /**
   * 获取照片列表
   */
  public async getPhotoList(params?: PhotoListParams): Promise<PageResponse<PhotoResponse>> {
    try {
      const queryParams: Record<string, string | number | boolean> = {};
      
      if (params) {
        if (params.page !== undefined) queryParams.page = params.page;
        if (params.pageSize !== undefined) queryParams.pageSize = params.pageSize;
        if (params.startDate) queryParams.startDate = params.startDate;
        if (params.endDate) queryParams.endDate = params.endDate;
        if (params.sortBy) queryParams.sortBy = params.sortBy;
        if (params.sortOrder) queryParams.sortOrder = params.sortOrder;
      }

      const response = await this.httpClient.get<PageResponse<PhotoResponse>>('/photos', queryParams);
      logger.info('PhotoService', `Got ${response.data.items.length} photos`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to get photo list: ${error.message}`);
      throw new Error(`Failed to get photo list: ${error.message}`);
    }
  }

  /**
   * 获取所有照片（用于兼容旧代码）
   */
  public async getAllPhotos(): Promise<PhotoModel[]> {
    try {
      const response = await this.getPhotoList({ page: 1, pageSize: 1000 });
      return response.items;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to get all photos: ${error.message}`);
      throw new Error(`Failed to get all photos: ${error.message}`);
    }
  }

  /**
   * 获取照片详情
   */
  public async getPhotoById(photoId: string): Promise<PhotoResponse> {
    try {
      const response = await this.httpClient.get<PhotoResponse>(`/photos/${photoId}`);
      logger.info('PhotoService', `Got photo: ${photoId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to get photo: ${error.message}`);
      throw new Error(`Failed to get photo: ${error.message}`);
    }
  }

  /**
   * 更新照片信息
   */
  public async updatePhoto(photoId: string, description: string): Promise<PhotoResponse> {
    try {
      interface UpdatePhotoRequest {
        description: string;
      }
      const request: UpdatePhotoRequest = {
        description
      };

      const response = await this.httpClient.put<PhotoResponse>(`/photos/${photoId}`, request);
      logger.info('PhotoService', `Photo updated: ${photoId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to update photo: ${error.message}`);
      throw new Error(`Failed to update photo: ${error.message}`);
    }
  }

  /**
   * 删除照片
   */
  public async deletePhoto(photoId: string): Promise<boolean> {
    try {
      const response = await this.httpClient.delete<SuccessResponse>(`/photos/${photoId}`);
      logger.info('PhotoService', `Photo deleted: ${photoId}`);
      return response.data.success;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to delete photo: ${error.message}`);
      throw new Error(`Failed to delete photo: ${error.message}`);
    }
  }

  /**
   * 批量删除照片
   */
  public async batchDeletePhotos(photoIds: string[]): Promise<BatchDeleteResponse> {
    try {
      const request: BatchDeleteRequest = {
        photoIds
      };

      const response = await this.httpClient.delete<BatchDeleteResponse>('/photos/batch', request);
      logger.info('PhotoService', `Batch deleted ${response.data.deletedCount} photos`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to batch delete photos: ${error.message}`);
      throw new Error(`Failed to batch delete photos: ${error.message}`);
    }
  }

  /**
   * 获取照片统计
   */
  public async getPhotoStats(): Promise<PhotoStatsResponse> {
    try {
      const response = await this.httpClient.get<PhotoStatsResponse>('/photos/stats');
      logger.info('PhotoService', `Got photo stats: ${response.data.totalPhotos} photos`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to get photo stats: ${error.message}`);
      throw new Error(`Failed to get photo stats: ${error.message}`);
    }
  }

  /**
   * 按日期范围获取照片
   */
  public async getPhotosByDateRange(
    startDate: number,
    endDate: number,
    page: number = 1,
    pageSize: number = 30
  ): Promise<PageResponse<PhotoResponse>> {
    try {
      const params: PhotoListParams = {
        startDate,
        endDate,
        page,
        pageSize
      };

      return await this.getPhotoList(params);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to get photos by date range: ${error.message}`);
      throw new Error(`Failed to get photos by date range: ${error.message}`);
    }
  }

  /**
   * 选择并上传照片（一站式方法）
   */
  public async selectAndUploadPhotos(maxCount: number = 9): Promise<BatchUploadResponse> {
    try {
      // 1. 选择照片
      const photoUris = await this.selectPhotos(maxCount);
      
      if (photoUris.length === 0) {
        return {
          totalCount: 0,
          successCount: 0,
          failedCount: 0,
          photos: []
        };
      }

      // 2. 上传照片
      return await this.batchUploadPhotos(photoUris);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('PhotoService', `Failed to select and upload photos: ${error.message}`);
      throw new Error(`Failed to select and upload photos: ${error.message}`);
    }
  }
}
