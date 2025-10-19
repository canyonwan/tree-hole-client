/**
 * 日记数据模型
 */
export interface DiaryModel {
  id?: number;
  title: string;
  content: string;
  mood: string; // 'happy', 'sad', 'calm', 'excited', 'tired'
  tags: string; // JSON字符串存储标签数组
  createTime: number;
  updateTime: number;
}

/**
 * 心情类型枚举
 */
export enum MoodType {
  HAPPY = 'happy',
  SAD = 'sad',
  CALM = 'calm',
  EXCITED = 'excited',
  TIRED = 'tired'
}

/**
 * 心情显示信息
 */
export interface MoodInfo {
  type: MoodType;
  emoji: string;
  label: string;
  color: string;
}

/**
 * 心情配置列表
 */
export const MOOD_CONFIG: MoodInfo[] = [
  { type: MoodType.HAPPY, emoji: '😊', label: '开心', color: '#FFD700' },
  { type: MoodType.SAD, emoji: '😢', label: '难过', color: '#87CEEB' },
  { type: MoodType.CALM, emoji: '😌', label: '平静', color: '#98FB98' },
  { type: MoodType.EXCITED, emoji: '🤩', label: '兴奋', color: '#FF69B4' },
  { type: MoodType.TIRED, emoji: '😴', label: '疲惫', color: '#D3D3D3' }
];

