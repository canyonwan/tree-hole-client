/**
 * 心情类型（从 API 导入）
 */
export type { MoodType } from './ApiTypes';

/**
 * 日记数据模型（后端返回）
 */
export interface DiaryModel {
  diaryId?: string;
  userId?: string;
  title?: string;
  content: string;
  contentPreview?: string;
  mood: string;  // 使用 string 以兼容 MoodType
  tags: string[];
  createdAt: number;
  updatedAt: number;
}

/**
 * 本地日记模型（用于兼容旧代码）
 */
export interface LocalDiaryModel {
  id?: number;
  title?: string;
  content: string;
  mood: string;
  tags: string; // JSON字符串存储标签数组
  createTime: number;
  updateTime: number;
}

/**
 * 心情显示信息
 */
export interface MoodInfo {
  type: string;
  emoji: string;
  label: string;
  color: string;
}

/**
 * 心情配置列表
 */
export const MOOD_CONFIG: MoodInfo[] = [
  { type: 'happy', emoji: '😊', label: '开心', color: '#FFD700' },
  { type: 'sad', emoji: '😢', label: '难过', color: '#87CEEB' },
  { type: 'calm', emoji: '😌', label: '平静', color: '#98FB98' },
  { type: 'excited', emoji: '🤩', label: '兴奋', color: '#FF69B4' },
  { type: 'tired', emoji: '😴', label: '疲惫', color: '#D3D3D3' }
];

