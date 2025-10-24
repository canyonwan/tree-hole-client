/**
 * 照片位置信息
 */
export interface PhotoLocation {
  latitude: number;
  longitude: number;
}

/**
 * 照片 EXIF 信息
 */
export interface PhotoExif {
  camera?: string;
  iso?: string;
  aperture?: string;
  shutterSpeed?: string;
  focalLength?: string;
  location?: PhotoLocation;
}

/**
 * 相册数据模型（后端返回）
 */
export interface PhotoModel {
  photoId: string;
  userId?: string;
  url: string;
  thumbnailUrl: string;
  description?: string;
  fileSize: number;
  width: number;
  height: number;
  format: string;
  exif?: PhotoExif;
  takenAt?: number;
  uploadedAt: number;
}

/**
 * 本地照片模型（用于兼容旧代码）
 */
export interface LocalPhotoModel {
  id?: number;
  filePath: string;
  description: string;
  createTime: number;
}

