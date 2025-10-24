import { http } from '@kit.NetworkKit';
import { Logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';

const logger: Logger = new Logger();

/**
 * HTTP 配置
 */
export class HttpConfig {
  // 修改为你的后端 API 地址
  public static readonly BASE_URL = 'https://api.example.com';
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000; // 30秒超时
  
  // Token 存储的 key
  public static readonly TOKEN_KEY = 'auth_token';
  public static readonly USER_ID_KEY = 'user_id';
}

/**
 * HTTP 响应结构
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

/**
 * 分页响应
 */
export interface PageResponse<T> {
  total: number;
  page: number;
  pageSize: number;
  items: T[];
}

/**
 * HTTP 客户端工具类
 */
export class HttpClient {
  private static instance: HttpClient;
  private context: Context;
  private prefs: preferences.Preferences | null = null;
  private token: string = '';

  private constructor(context: Context) {
    this.context = context;
  }

  /**
   * 获取单例
   */
  public static getInstance(context: Context): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient(context);
    }
    return HttpClient.instance;
  }

  /**
   * 初始化
   */
  public async init(): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(this.context, 'http_preferences');
      this.token = await this.prefs.get(HttpConfig.TOKEN_KEY, '') as string;
      logger.info('HttpClient', 'HttpClient initialized');
    } catch (err) {
      const error = err as BusinessError;
      logger.error('HttpClient', `Failed to init HttpClient: ${error.message}`);
    }
  }

  /**
   * 设置 Token
   */
  public async setToken(token: string): Promise<void> {
    this.token = token;
    if (this.prefs) {
      await this.prefs.put(HttpConfig.TOKEN_KEY, token);
      await this.prefs.flush();
    }
  }

  /**
   * 获取 Token
   */
  public getToken(): string {
    return this.token;
  }

  /**
   * 清除 Token
   */
  public async clearToken(): Promise<void> {
    this.token = '';
    if (this.prefs) {
      await this.prefs.delete(HttpConfig.TOKEN_KEY);
      await this.prefs.delete(HttpConfig.USER_ID_KEY);
      await this.prefs.flush();
    }
  }

  /**
   * 保存用户ID
   */
  public async setUserId(userId: string): Promise<void> {
    if (this.prefs) {
      await this.prefs.put(HttpConfig.USER_ID_KEY, userId);
      await this.prefs.flush();
    }
  }

  /**
   * 获取用户ID
   */
  public async getUserId(): Promise<string> {
    if (this.prefs) {
      return await this.prefs.get(HttpConfig.USER_ID_KEY, '') as string;
    }
    return '';
  }

  /**
   * GET 请求
   */
  public async get<T>(endpoint: string, params?: Record<string, string | number | boolean>): Promise<ApiResponse<T>> {
    return this.request<T>('GET', endpoint, undefined, params);
  }

  /**
   * POST 请求
   */
  public async post<T>(endpoint: string, data?: object, params?: Record<string, string | number | boolean>): Promise<ApiResponse<T>> {
    return this.request<T>('POST', endpoint, data, params);
  }

  /**
   * PUT 请求
   */
  public async put<T>(endpoint: string, data?: object, params?: Record<string, string | number | boolean>): Promise<ApiResponse<T>> {
    return this.request<T>('PUT', endpoint, data, params);
  }

  /**
   * DELETE 请求
   */
  public async delete<T>(endpoint: string, data?: object, params?: Record<string, string | number | boolean>): Promise<ApiResponse<T>> {
    return this.request<T>('DELETE', endpoint, data, params);
  }

  /**
   * 上传文件
   */
  public async uploadFile<T>(endpoint: string, filePath: string, fieldName: string = 'file', extraData?: Record<string, string>): Promise<ApiResponse<T>> {
    try {
      const url = this.buildUrl(endpoint);
      const httpRequest = http.createHttp();

      // 构建 multipart/form-data
      const fileItem: http.MultiFormData = {
        name: fieldName,
        contentType: 'image/jpeg',
        filePath: filePath,
        remoteFileName: filePath.substring(filePath.lastIndexOf('/') + 1)
      };
      const files: Array<http.MultiFormData> = [fileItem];

      const emptyData: Record<string, string> = {};
      const requestOption: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: this.buildHeaders(true),
        extraData: extraData || emptyData,
        multiFormDataList: files,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: HttpConfig.TIMEOUT,
        readTimeout: HttpConfig.TIMEOUT
      };

      logger.info('HttpClient', `Uploading file to: ${url}`);
      const response = await httpRequest.request(url, requestOption);
      
      const result = this.handleResponse<T>(response);
      httpRequest.destroy();
      return result;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('HttpClient', `Upload failed: ${error.message}`);
      throw new Error(`Upload failed: ${error.message}`);
    }
  }

  /**
   * 通用请求方法
   */
  private async request<T>(
    method: string,
    endpoint: string,
    data?: object,
    params?: Record<string, string | number | boolean>
  ): Promise<ApiResponse<T>> {
    try {
      const url = this.buildUrl(endpoint, params);
      const httpRequest = http.createHttp();

      const requestOption: http.HttpRequestOptions = {
        method: method as http.RequestMethod,
        header: this.buildHeaders(),
        extraData: data,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: HttpConfig.TIMEOUT,
        readTimeout: HttpConfig.TIMEOUT
      };

      logger.info('HttpClient', `${method} ${url}`);
      if (data) {
        logger.debug('HttpClient', `Request data: ${JSON.stringify(data)}`);
      }

      const response = await httpRequest.request(url, requestOption);
      const result = this.handleResponse<T>(response);
      
      httpRequest.destroy();
      return result;
    } catch (err) {
      const error = err as BusinessError;
      logger.error('HttpClient', `Request failed: ${error.message}`);
      throw this.handleError(error);
    }
  }

  /**
   * 构建完整 URL
   */
  private buildUrl(endpoint: string, params?: Record<string, string | number | boolean>): string {
    let url = `${HttpConfig.BASE_URL}${HttpConfig.API_VERSION}${endpoint}`;
    
    if (params) {
      const queryString = Object.entries(params)
        .map((entry: [string, string | number | boolean]) => {
          const key = entry[0];
          const value = entry[1];
          return `${key}=${encodeURIComponent(String(value))}`;
        })
        .join('&');
      
      if (queryString) {
        url += `?${queryString}`;
      }
    }
    
    return url;
  }

  /**
   * 构建请求头
   */
  private buildHeaders(isMultipart: boolean = false): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': isMultipart ? 'multipart/form-data' : 'application/json',
      'Accept': 'application/json'
    };

    // 如果有 token，添加到请求头
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return headers;
  }

  /**
   * 处理响应
   */
  private handleResponse<T>(response: http.HttpResponse): ApiResponse<T> {
    const statusCode = response.responseCode;
    
    logger.info('HttpClient', `Response status: ${statusCode}`);
    
    // 检查 HTTP 状态码
    if (statusCode < 200 || statusCode >= 300) {
      throw new Error(`HTTP Error: ${statusCode}`);
    }

    // 解析响应数据
    let apiResponse: ApiResponse<T>;
    
    if (typeof response.result === 'string') {
      apiResponse = JSON.parse(response.result) as ApiResponse<T>;
    } else {
      apiResponse = response.result as ApiResponse<T>;
    }

    // 检查业务状态码
    if (apiResponse.code !== 200) {
      logger.warn('HttpClient', `API Error: ${apiResponse.code} - ${apiResponse.message}`);
      throw new Error(apiResponse.message || `API Error: ${apiResponse.code}`);
    }

    logger.debug('HttpClient', `Response data: ${JSON.stringify(apiResponse.data)}`);
    return apiResponse;
  }

  /**
   * 错误处理
   */
  private handleError(error: BusinessError): Error {
    logger.error('HttpClient', `Error: ${error.code} - ${error.message}`);
    
    // 根据错误码返回友好的错误信息
    switch (error.code) {
      case 401:
        return new Error('未授权，请重新登录');
      case 403:
        return new Error('禁止访问');
      case 404:
        return new Error('资源不存在');
      case 500:
        return new Error('服务器内部错误');
      default:
        return new Error(error.message || '网络请求失败');
    }
  }
}

