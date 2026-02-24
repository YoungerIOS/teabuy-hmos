import { ApiConfig } from './ApiConfig';
import { HeaderItem, RequestConfig } from './Interceptors';
import { http } from '@kit.NetworkKit';
import { UserStore } from '../store/UserStore';

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
    const token: string = UserStore.getToken().length > 0 ? UserStore.getToken() : ApiConfig.authToken;
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
      if (resp.responseCode < 200 || resp.responseCode >= 300) {
        throw new Error(payload.message);
      }
      return payload;
    } finally {
      req.destroy();
    }
  }
}
