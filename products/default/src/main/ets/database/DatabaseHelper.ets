import { relationalStore } from '@kit.ArkData';
import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { LocalDiaryModel } from '../models/DiaryModel';
import { LocalPhotoModel } from '../models/PhotoModel';

const logger: Logger = new Logger();
const DB_NAME = 'SecretSpace.db';
const DB_VERSION = 1;

/**
 * 数据库管理类
 */
export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private store: relationalStore.RdbStore | null = null;
  private context: Context;

  private constructor(context: Context) {
    this.context = context;
  }

  public static getInstance(context: Context): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper(context);
    }
    return DatabaseHelper.instance;
  }

  /**
   * 初始化数据库
   */
  public async initDatabase(): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.store = await relationalStore.getRdbStore(this.context, config);
      await this.createTables();
      logger.info('DatabaseHelper', 'Database initialized successfully');
    } catch (err) {
      const error = err as BusinessError;
      logger.error('DatabaseHelper', `Failed to init database: ${error.message}`);
      throw new Error(`Failed to init database: ${error.message}`);
    }
  }

  /**
   * 创建数据表
   */
  private async createTables(): Promise<void> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    // 创建日记表
    const createDiaryTable = `
      CREATE TABLE IF NOT EXISTS diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        tags TEXT,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `;

    // 创建相册表
    const createPhotoTable = `
      CREATE TABLE IF NOT EXISTS photo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filePath TEXT NOT NULL,
        description TEXT,
        createTime INTEGER NOT NULL
      )
    `;

    await this.store.executeSql(createDiaryTable);
    await this.store.executeSql(createPhotoTable);
  }

  /**
   * 插入日记
   */
  public async insertDiary(diary: LocalDiaryModel): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      title: diary.title ?? '',
      content: diary.content,
      mood: diary.mood,
      tags: diary.tags,
      createTime: diary.createTime,
      updateTime: diary.updateTime
    };

    return await this.store.insert('diary', valueBucket);
  }

  /**
   * 更新日记
   */
  public async updateDiary(diary: LocalDiaryModel): Promise<number> {
    if (!this.store || !diary.id) {
      throw new Error('Database not initialized or diary id is missing');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      title: diary.title ?? '',
      content: diary.content,
      mood: diary.mood,
      tags: diary.tags,
      updateTime: diary.updateTime
    };

    const predicates = new relationalStore.RdbPredicates('diary');
    predicates.equalTo('id', diary.id);

    return await this.store.update(valueBucket, predicates);
  }

  /**
   * 删除日记
   */
  public async deleteDiary(id: number): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('diary');
    predicates.equalTo('id', id);

    return await this.store.delete(predicates);
  }

  /**
   * 查询所有日记
   */
  public async queryAllDiaries(): Promise<LocalDiaryModel[]> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('diary');
    predicates.orderByDesc('createTime');

    const resultSet = await this.store.query(predicates);
    const diaries: LocalDiaryModel[] = [];

    while (resultSet.goToNextRow()) {
      const tagsIndex = resultSet.getColumnIndex('tags');
      const diary: LocalDiaryModel = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        mood: resultSet.getString(resultSet.getColumnIndex('mood')),
        tags: resultSet.isColumnNull(tagsIndex) ? '' : resultSet.getString(tagsIndex),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime')),
        updateTime: resultSet.getLong(resultSet.getColumnIndex('updateTime'))
      };
      diaries.push(diary);
    }

    resultSet.close();
    return diaries;
  }

  /**
   * 根据ID查询日记
   */
  public async queryDiaryById(id: number): Promise<LocalDiaryModel | null> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('diary');
    predicates.equalTo('id', id);

    const resultSet = await this.store.query(predicates);
    let diary: LocalDiaryModel | null = null;

    if (resultSet.goToFirstRow()) {
      const tagsIndex = resultSet.getColumnIndex('tags');
      diary = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        mood: resultSet.getString(resultSet.getColumnIndex('mood')),
        tags: resultSet.isColumnNull(tagsIndex) ? '' : resultSet.getString(tagsIndex),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime')),
        updateTime: resultSet.getLong(resultSet.getColumnIndex('updateTime'))
      };
    }

    resultSet.close();
    return diary;
  }

  /**
   * 插入照片
   */
  public async insertPhoto(photo: LocalPhotoModel): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      filePath: photo.filePath,
      description: photo.description || '',
      createTime: photo.createTime
    };

    return await this.store.insert('photo', valueBucket);
  }

  /**
   * 删除照片
   */
  public async deletePhoto(id: number): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('photo');
    predicates.equalTo('id', id);

    return await this.store.delete(predicates);
  }

  /**
   * 查询所有照片
   */
  public async queryAllPhotos(): Promise<LocalPhotoModel[]> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('photo');
    predicates.orderByDesc('createTime');

    const resultSet = await this.store.query(predicates);
    const photos: LocalPhotoModel[] = [];

    while (resultSet.goToNextRow()) {
      const descIndex = resultSet.getColumnIndex('description');
      const photo: LocalPhotoModel = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        filePath: resultSet.getString(resultSet.getColumnIndex('filePath')),
        description: resultSet.isColumnNull(descIndex) ? '' : resultSet.getString(descIndex),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
      };
      photos.push(photo);
    }

    resultSet.close();
    return photos;
  }
}

