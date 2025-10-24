import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpClient, PageResponse } from '../utils/HttpClient';
import { DiaryModel } from '../models/DiaryModel';
import {
  CreateDiaryRequest,
  UpdateDiaryRequest,
  DiaryResponse,
  DiaryListParams,
  BatchDeleteRequest,
  BatchDeleteResponse,
  TagsResponse,
  MoodStatsResponse,
  SuccessResponse,
  MoodType
} from '../models/ApiTypes';

const logger: Logger = new Logger();

/**
 * 日记业务服务类 - 对接后端 API
 */
export class DiaryService {
  private httpClient: HttpClient;

  constructor(context: Context) {
    this.httpClient = HttpClient.getInstance(context);
  }

  /**
   * 创建新日记
   */
  public async createDiary(
    title: string | undefined,
    content: string,
    mood: MoodType,
    tags: string[]
  ): Promise<DiaryResponse> {
    try {
      const request: CreateDiaryRequest = {
        title,
        content,
        mood,
        tags,
        createdDate: Date.now()
      };

      const response = await this.httpClient.post<DiaryResponse>('/diaries', request);
      logger.info('DiaryService', `Diary created: ${response.data.diaryId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to create diary: ${error.message}`);
      throw new Error(`Failed to create diary: ${error.message}`);
    }
  }

  /**
   * 获取日记列表
   */
  public async getDiaryList(params?: DiaryListParams): Promise<PageResponse<DiaryResponse>> {
    try {
      const queryParams: Record<string, string | number | boolean> = {};
      
      if (params) {
        if (params.page !== undefined) queryParams.page = params.page;
        if (params.pageSize !== undefined) queryParams.pageSize = params.pageSize;
        if (params.keyword) queryParams.keyword = params.keyword;
        if (params.mood) queryParams.mood = params.mood;
        if (params.tags) queryParams.tags = params.tags;
        if (params.startDate) queryParams.startDate = params.startDate;
        if (params.endDate) queryParams.endDate = params.endDate;
        if (params.sortBy) queryParams.sortBy = params.sortBy;
        if (params.sortOrder) queryParams.sortOrder = params.sortOrder;
      }

      const response = await this.httpClient.get<PageResponse<DiaryResponse>>('/diaries', queryParams);
      logger.info('DiaryService', `Got ${response.data.items.length} diaries`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get diary list: ${error.message}`);
      throw new Error(`Failed to get diary list: ${error.message}`);
    }
  }

  /**
   * 获取所有日记（用于兼容旧代码）
   */
  public async getAllDiaries(): Promise<DiaryModel[]> {
    try {
      const response = await this.getDiaryList({ page: 1, pageSize: 1000 });
      return this.convertToDiaryModels(response.items);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get all diaries: ${error.message}`);
      throw new Error(`Failed to get all diaries: ${error.message}`);
    }
  }

  /**
   * 获取日记详情
   */
  public async getDiaryById(diaryId: string): Promise<DiaryResponse> {
    try {
      const response = await this.httpClient.get<DiaryResponse>(`/diaries/${diaryId}`);
      logger.info('DiaryService', `Got diary: ${diaryId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get diary: ${error.message}`);
      throw new Error(`Failed to get diary: ${error.message}`);
    }
  }

  /**
   * 更新日记
   */
  public async updateDiary(
    diaryId: string,
    title: string | undefined,
    content: string,
    mood: MoodType,
    tags: string[]
  ): Promise<DiaryResponse> {
    try {
      const request: UpdateDiaryRequest = {
        title,
        content,
        mood,
        tags
      };

      const response = await this.httpClient.put<DiaryResponse>(`/diaries/${diaryId}`, request);
      logger.info('DiaryService', `Diary updated: ${diaryId}`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to update diary: ${error.message}`);
      throw new Error(`Failed to update diary: ${error.message}`);
    }
  }

  /**
   * 删除日记
   */
  public async deleteDiary(diaryId: string): Promise<boolean> {
    try {
      const response = await this.httpClient.delete<SuccessResponse>(`/diaries/${diaryId}`);
      logger.info('DiaryService', `Diary deleted: ${diaryId}`);
      return response.data.success;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to delete diary: ${error.message}`);
      throw new Error(`Failed to delete diary: ${error.message}`);
    }
  }

  /**
   * 批量删除日记
   */
  public async batchDeleteDiaries(diaryIds: string[]): Promise<BatchDeleteResponse> {
    try {
      const request: BatchDeleteRequest = {
        diaryIds
      };

      const response = await this.httpClient.delete<BatchDeleteResponse>('/diaries/batch', request);
      logger.info('DiaryService', `Batch deleted ${response.data.deletedCount} diaries`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to batch delete diaries: ${error.message}`);
      throw new Error(`Failed to batch delete diaries: ${error.message}`);
    }
  }

  /**
   * 获取所有标签
   */
  public async getAllTags(): Promise<TagsResponse> {
    try {
      const response = await this.httpClient.get<TagsResponse>('/diaries/tags');
      logger.info('DiaryService', `Got ${response.data.tags.length} tags`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get tags: ${error.message}`);
      throw new Error(`Failed to get tags: ${error.message}`);
    }
  }

  /**
   * 获取心情统计
   */
  public async getMoodStats(startDate?: number, endDate?: number): Promise<MoodStatsResponse> {
    try {
      const queryParams: Record<string, string | number | boolean> = {};
      if (startDate) queryParams.startDate = startDate;
      if (endDate) queryParams.endDate = endDate;

      const response = await this.httpClient.get<MoodStatsResponse>('/diaries/mood-stats', queryParams);
      logger.info('DiaryService', `Got mood stats for ${response.data.totalDiaries} diaries`);
      return response.data;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get mood stats: ${error.message}`);
      throw new Error(`Failed to get mood stats: ${error.message}`);
    }
  }

  /**
   * 搜索日记
   */
  public async searchDiaries(keyword: string, page: number = 1, pageSize: number = 20): Promise<PageResponse<DiaryResponse>> {
    try {
      const params: DiaryListParams = {
        keyword,
        page,
        pageSize
      };

      return await this.getDiaryList(params);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to search diaries: ${error.message}`);
      throw new Error(`Failed to search diaries: ${error.message}`);
    }
  }

  /**
   * 按心情筛选日记
   */
  public async getDiariesByMood(mood: MoodType, page: number = 1, pageSize: number = 20): Promise<PageResponse<DiaryResponse>> {
    try {
      const params: DiaryListParams = {
        mood,
        page,
        pageSize
      };

      return await this.getDiaryList(params);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get diaries by mood: ${error.message}`);
      throw new Error(`Failed to get diaries by mood: ${error.message}`);
    }
  }

  /**
   * 按标签筛选日记
   */
  public async getDiariesByTags(tags: string[], page: number = 1, pageSize: number = 20): Promise<PageResponse<DiaryResponse>> {
    try {
      const params: DiaryListParams = {
        tags: tags.join(','),
        page,
        pageSize
      };

      return await this.getDiaryList(params);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get diaries by tags: ${error.message}`);
      throw new Error(`Failed to get diaries by tags: ${error.message}`);
    }
  }

  /**
   * 按日期范围获取日记
   */
  public async getDiariesByDateRange(
    startDate: number,
    endDate: number,
    page: number = 1,
    pageSize: number = 20
  ): Promise<PageResponse<DiaryResponse>> {
    try {
      const params: DiaryListParams = {
        startDate,
        endDate,
        page,
        pageSize
      };

      return await this.getDiaryList(params);
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DiaryService', `Failed to get diaries by date range: ${error.message}`);
      throw new Error(`Failed to get diaries by date range: ${error.message}`);
    }
  }

  /**
   * 转换 DiaryResponse 为 DiaryModel（用于兼容旧代码）
   */
  private convertToDiaryModels(diaryResponses: DiaryResponse[]): DiaryModel[] {
    return diaryResponses.map((diary: DiaryResponse): DiaryModel => {
      const model: DiaryModel = {
        diaryId: diary.diaryId,
        userId: diary.userId,
        title: diary.title,
        content: diary.content,
        contentPreview: diary.contentPreview,
        mood: diary.mood,
        tags: diary.tags,
        createdAt: diary.createdAt,
        updatedAt: diary.updatedAt
      };
      return model;
    });
  }

  /**
   * 解析标签字符串（用于兼容旧代码）
   */
  public parseTags(tagsJson: string): string[] {
    try {
      return JSON.parse(tagsJson) as string[];
    } catch {
      return [];
    }
  }
}
