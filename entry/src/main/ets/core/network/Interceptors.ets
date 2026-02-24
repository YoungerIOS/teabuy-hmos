export type HttpMethod = 'GET' | 'POST' | 'PATCH' | 'DELETE';

export class HeaderItem {
  key: string = '';
  value: string = '';
}

export class RequestConfig {
  path: string = '';
  method: HttpMethod = 'GET';
  headers: HeaderItem[] = [];
  body: string = '';
  hasBody: boolean = false;
}

export function createGetRequest(path: string): RequestConfig {
  const config = new RequestConfig();
  config.path = path;
  config.method = 'GET';
  return config;
}
