import { ApiConfig } from './ApiConfig';
import { HeaderItem, RequestConfig } from './Interceptors';
import { http } from '@kit.NetworkKit';
import { UserStore } from '../store/UserStore';
import { AuthRepository } from '../../features/auth/data/AuthRepository';

export class ApiResponse<T> {
  code: number = -1;
  message: string = '';
  data: T;

  constructor(data: T) {
    this.data = data;
  }
}

export class HttpClient {
  private static toRequestMethod(method: string): http.RequestMethod {
    if (method === 'POST') {
      return http.RequestMethod.POST;
    }
    if (method === 'PATCH') {
      return http.RequestMethod.PUT;
    }
    if (method === 'DELETE') {
      return http.RequestMethod.DELETE;
    }
    return http.RequestMethod.GET;
  }

  static async request<T>(config: RequestConfig): Promise<ApiResponse<T>> {
    return await HttpClient.requestWithRetry(config, false);
  }

  private static async requestWithRetry<T>(config: RequestConfig, isRetry: boolean): Promise<ApiResponse<T>> {
    const url: string = `${ApiConfig.baseUrl}${ApiConfig.apiPrefix}${config.path}`;
    const requestHeaders: HeaderItem[] = [];
    for (let i = 0; i < config.headers.length; i++) {
      requestHeaders.push(config.headers[i]);
    }
    let hasAuth: boolean = false;
    for (let i = 0; i < requestHeaders.length; i++) {
      if (requestHeaders[i].key === 'Authorization') {
        hasAuth = true;
        break;
      }
    }
    const token: string = UserStore.getAccessToken().length > 0 ? UserStore.getAccessToken() : ApiConfig.authToken;
    if (token.length > 0 && !hasAuth) {
      const authHeader = new HeaderItem();
      authHeader.key = 'Authorization';
      authHeader.value = `Bearer ${token}`;
      requestHeaders.push(authHeader);
    }

    const headerObj: Record<string, Object> = {};
    headerObj['Content-Type'] = 'application/json';
    for (let i = 0; i < requestHeaders.length; i++) {
      headerObj[requestHeaders[i].key] = requestHeaders[i].value;
    }
    if (!headerObj['Idempotency-Key']) {
      headerObj['Idempotency-Key'] = `${Date.now()}_${Math.floor(Math.random() * 1000000)}`;
    }

    const req = http.createHttp();
    const options: http.HttpRequestOptions = {
      method: HttpClient.toRequestMethod(config.method),
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: ApiConfig.timeoutMs,
      readTimeout: ApiConfig.timeoutMs,
      header: headerObj
    };
    if (config.hasBody) {
      options.extraData = config.body;
    }

    try {
      const resp: http.HttpResponse = await req.request(url, options);
      const resultText: string = typeof resp.result === 'string' ? resp.result : JSON.stringify(resp.result);
      let payload: ApiResponse<T>;
      try {
        payload = JSON.parse(resultText) as ApiResponse<T>;
      } catch (parseErr) {
        const preview: string = resultText.length > 180 ? resultText.slice(0, 180) : resultText;
        throw new Error(
          `Non-JSON response. url=${url}, code=${resp.responseCode}, body=${preview}`
        );
      }
      
      // 检查是否是 Token 过期错误 (通常是 401)
      if (resp.responseCode === 401 && !isRetry) {
        console.log('=== Token expired (401), attempting to refresh... ===');
        console.log('Request URL:', url);
        console.log('isRetry:', isRetry);
        try {
          // 刷新 Token
          const newToken = await AuthRepository.refreshToken();
          console.log('Token refreshed successfully, new token length:', newToken.length);
          // 使用新 Token 重试请求
          console.log('Retrying original request with new token...');
          return await HttpClient.requestWithRetry(config, true);
        } catch (refreshError) {
          console.error('Token refresh failed:', refreshError);
          throw new Error('Authentication failed. Please login again.');
        }
      }
      
      if (resp.responseCode < 200 || resp.responseCode >= 300) {
        throw new Error(payload.message);
      }
      return payload;
    } finally {
      req.destroy();
    }
  }
}
