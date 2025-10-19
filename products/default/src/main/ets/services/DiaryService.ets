import { DatabaseHelper } from '../database/DatabaseHelper';
import { DiaryModel } from '../models/DiaryModel';
import { Logger } from '../../../common/src/main/ets/utils/Logger';

const logger = new Logger();

/**
 * 日记业务服务类
 */
export class DiaryService {
  private dbHelper: DatabaseHelper;

  constructor(context: Context) {
    this.dbHelper = DatabaseHelper.getInstance(context);
  }

  /**
   * 创建新日记
   */
  public async createDiary(title: string, content: string, mood: string, tags: string[]): Promise<number> {
    try {
      const now = Date.now();
      const diary: DiaryModel = {
        title,
        content,
        mood,
        tags: JSON.stringify(tags),
        createTime: now,
        updateTime: now
      };

      const id = await this.dbHelper.insertDiary(diary);
      logger.info('DiaryService', `Diary created with id: ${id}`);
      return id;
    } catch (err) {
      logger.error('DiaryService', `Failed to create diary: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 更新日记
   */
  public async updateDiary(id: number, title: string, content: string, mood: string, tags: string[]): Promise<void> {
    try {
      const existingDiary = await this.dbHelper.queryDiaryById(id);
      if (!existingDiary) {
        throw new Error('Diary not found');
      }

      const diary: DiaryModel = {
        id,
        title,
        content,
        mood,
        tags: JSON.stringify(tags),
        createTime: existingDiary.createTime,
        updateTime: Date.now()
      };

      await this.dbHelper.updateDiary(diary);
      logger.info('DiaryService', `Diary updated: ${id}`);
    } catch (err) {
      logger.error('DiaryService', `Failed to update diary: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 删除日记
   */
  public async deleteDiary(id: number): Promise<void> {
    try {
      await this.dbHelper.deleteDiary(id);
      logger.info('DiaryService', `Diary deleted: ${id}`);
    } catch (err) {
      logger.error('DiaryService', `Failed to delete diary: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 获取所有日记
   */
  public async getAllDiaries(): Promise<DiaryModel[]> {
    try {
      const diaries = await this.dbHelper.queryAllDiaries();
      return diaries;
    } catch (err) {
      logger.error('DiaryService', `Failed to get diaries: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 根据ID获取日记
   */
  public async getDiaryById(id: number): Promise<DiaryModel | null> {
    try {
      return await this.dbHelper.queryDiaryById(id);
    } catch (err) {
      logger.error('DiaryService', `Failed to get diary: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 解析标签字符串
   */
  public parseTags(tagsJson: string): string[] {
    try {
      return JSON.parse(tagsJson) as string[];
    } catch {
      return [];
    }
  }
}

