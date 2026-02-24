import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';

export class LoginUser {
  id: string = '';
  username: string = '';
  displayName: string = '';
}

export class LoginData {
  accessToken: string = '';
  refreshToken: string = '';
  user: LoginUser = new LoginUser();
}

export class LoginRequest {
  username: string = '';
  password: string = '';
}

export class AuthRepository {
  static async login(username: string, password: string): Promise<LoginData> {
    const req = new RequestConfig();
    req.path = '/auth/login';
    req.method = 'POST';
    req.hasBody = true;
    const body = new LoginRequest();
    body.username = username;
    body.password = password;
    req.body = JSON.stringify(body);
    const result = await HttpClient.request<LoginData>(req);
    return result.data;
  }
}
