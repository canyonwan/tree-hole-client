# API 配置示例

## 环境配置

### 开发环境

```typescript
// products/default/src/main/ets/utils/HttpClient.ets

export class HttpConfig {
  // 开发环境 - 本地后端
  public static readonly BASE_URL = 'http://localhost:3000';
  // 或者使用局域网 IP
  // public static readonly BASE_URL = 'http://192.168.1.100:3000';
  
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000; // 30秒
}
```

### 测试环境

```typescript
export class HttpConfig {
  // 测试环境
  public static readonly BASE_URL = 'https://test-api.example.com';
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000;
}
```

### 生产环境

```typescript
export class HttpConfig {
  // 生产环境
  public static readonly BASE_URL = 'https://api.example.com';
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000;
}
```

---

## 多环境配置方案

如果需要支持多环境切换，可以使用以下方案：

### 方案 1: 使用环境变量

```typescript
// products/default/src/main/ets/utils/HttpClient.ets

export class HttpConfig {
  private static getBaseUrl(): string {
    // 根据构建类型选择不同的 API 地址
    const buildType = AppStorage.get<string>('buildType') || 'production';
    
    switch (buildType) {
      case 'development':
        return 'http://192.168.1.100:3000';
      case 'testing':
        return 'https://test-api.example.com';
      case 'production':
        return 'https://api.example.com';
      default:
        return 'https://api.example.com';
    }
  }

  public static readonly BASE_URL = HttpConfig.getBaseUrl();
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000;
}
```

### 方案 2: 使用配置文件

创建配置文件：`products/default/src/main/ets/config/env.config.ets`

```typescript
export interface EnvConfig {
  baseUrl: string;
  apiVersion: string;
  timeout: number;
}

export const ENV_CONFIGS: Record<string, EnvConfig> = {
  development: {
    baseUrl: 'http://192.168.1.100:3000',
    apiVersion: '/api/v1',
    timeout: 30000
  },
  testing: {
    baseUrl: 'https://test-api.example.com',
    apiVersion: '/api/v1',
    timeout: 30000
  },
  production: {
    baseUrl: 'https://api.example.com',
    apiVersion: '/api/v1',
    timeout: 30000
  }
};

// 当前环境（在编译时或运行时切换）
export const CURRENT_ENV = 'production';

export function getEnvConfig(): EnvConfig {
  return ENV_CONFIGS[CURRENT_ENV] || ENV_CONFIGS.production;
}
```

然后在 HttpClient 中使用：

```typescript
import { getEnvConfig } from '../config/env.config';

const envConfig = getEnvConfig();

export class HttpConfig {
  public static readonly BASE_URL = envConfig.baseUrl;
  public static readonly API_VERSION = envConfig.apiVersion;
  public static readonly TIMEOUT = envConfig.timeout;
}
```

---

## 网络权限配置

### module.json5

```json5
{
  "module": {
    "name": "default",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "DefaultAbility",
    "deviceTypes": [
      "default",
      "tablet"
    ],
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:permission_internet_reason",
        "usedScene": {
          "abilities": [
            "DefaultAbility"
          ],
          "when": "inuse"
        }
      }
    ],
    // ... 其他配置
  }
}
```

### string.json

在 `products/default/src/main/resources/base/element/string.json` 中添加权限说明：

```json
{
  "string": [
    {
      "name": "permission_internet_reason",
      "value": "需要访问网络以同步您的日记和照片"
    }
  ]
}
```

---

## API 超时配置

根据网络环境调整超时时间：

```typescript
export class HttpConfig {
  // WiFi 环境下可以使用较短的超时时间
  public static readonly TIMEOUT = 15000; // 15秒

  // 移动网络环境下建议使用较长的超时时间
  // public static readonly TIMEOUT = 30000; // 30秒

  // 文件上传超时时间（可以单独设置）
  public static readonly UPLOAD_TIMEOUT = 60000; // 60秒
}
```

---

## HTTPS 证书配置

如果后端使用自签名证书（仅开发环境），需要配置证书信任。

⚠️ **注意**: 生产环境必须使用有效的 SSL 证书，不应信任自签名证书。

---

## 调试配置

### 开启详细日志

在 HttpClient 中已经集成了日志输出，可以通过 Logger 查看：

```typescript
// 在开发环境下可以设置日志级别
const logger: Logger = new Logger();
logger.setLogLevel(LogLevel.DEBUG); // 开启调试日志
```

### 模拟 API 响应（Mock）

在开发初期，如果后端接口还未就绪，可以使用 Mock 数据：

```typescript
// 创建 MockHttpClient
export class MockHttpClient extends HttpClient {
  public async get<T>(endpoint: string, params?: Record<string, any>): Promise<ApiResponse<T>> {
    // 返回模拟数据
    return {
      code: 200,
      message: 'success',
      data: {} as T,
      timestamp: Date.now()
    };
  }
  
  // ... 其他方法的 Mock 实现
}
```

---

## 完整配置检查清单

在部署前，请检查以下配置：

- [ ] API 地址已配置为正确的后端地址
- [ ] 使用 HTTPS 协议（生产环境）
- [ ] 网络权限已添加到 module.json5
- [ ] 权限说明已添加到 string.json
- [ ] 超时时间已根据网络环境调整
- [ ] 移除所有开发环境的调试代码
- [ ] Token 存储安全（已使用加密存储）
- [ ] 敏感信息不在代码中硬编码

---

## 常见配置问题

### Q1: 本地开发时无法连接后端

**解决方案**:
- 确保手机/模拟器与开发机在同一局域网
- 使用局域网 IP 地址而不是 localhost
- 检查防火墙是否阻止了连接

### Q2: HTTPS 证书错误

**解决方案**:
- 使用有效的 SSL 证书
- 检查证书是否过期
- 确保域名与证书匹配

### Q3: 请求超时

**解决方案**:
- 增加超时时间
- 检查网络连接
- 优化后端响应速度

### Q4: 跨域问题

**解决方案**:
- 后端配置 CORS
- 使用相同域名或配置允许的域名

---

## 推荐配置

### 开发环境推荐配置

```typescript
export class HttpConfig {
  public static readonly BASE_URL = 'http://192.168.1.100:3000'; // 局域网IP
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 30000; // 较长的超时时间便于调试
  public static readonly DEBUG = true; // 开启调试模式
}
```

### 生产环境推荐配置

```typescript
export class HttpConfig {
  public static readonly BASE_URL = 'https://api.example.com'; // HTTPS
  public static readonly API_VERSION = '/api/v1';
  public static readonly TIMEOUT = 15000; // 较短的超时时间
  public static readonly DEBUG = false; // 关闭调试模式
}
```

---

**配置完成后，请参考 `API_QUICK_START.md` 开始使用！**

