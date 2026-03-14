import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';
import { UserStore } from '../../../core/store/UserStore';

export class RefreshTokenResponse {
  accessToken: string = '';
  refreshToken: string = '';
  expiresIn: number = 0;
}

export class User {
  id: string = '';
  username: string = '';
  displayName: string = '';
  role: string = '';
}

export class LoginResponse {
  accessToken: string = '';
  refreshToken: string = '';
  user: User = new User();
}

export class RegisterResponse {
  accessToken: string = '';
  refreshToken: string = '';
  user: User = new User();
}

export class AuthRepository {
  /**
   * 用户登录
   */
  static async login(username: string, password: string): Promise<LoginResponse> {
    const req = new RequestConfig();
    req.path = '/auth/login';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ username, password });
    
    const result = await HttpClient.request<LoginResponse>(req);
    console.log('Login response:', JSON.stringify(result));
    console.log('Login result.data:', JSON.stringify(result.data));
    
    const data = result.data || new LoginResponse();
    
    if (data.accessToken && data.accessToken.length > 0) {
      // 保存 Access Token 和 Refresh Token
      UserStore.setSession(data.accessToken, data.user?.id || '', data.refreshToken);
    }
    
    return data;
  }

  /**
   * 用户注册
   */
  static async register(username: string, password: string, code: string): Promise<RegisterResponse> {
    const req = new RequestConfig();
    req.path = '/auth/register';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ username, password, code });
    
    const result = await HttpClient.request<RegisterResponse>(req);
    const data = result.data || new RegisterResponse();
    
    if (data.accessToken && data.accessToken.length > 0) {
      // 保存 Access Token 和 Refresh Token
      UserStore.setSession(data.accessToken, data.user?.id || '', data.refreshToken);
    }
    
    return data;
  }

  /**
   * 用户登出
   */
  static async logout(): Promise<void> {
    const req = new RequestConfig();
    req.path = '/auth/logout';
    req.method = 'POST';
    
    try {
      await HttpClient.request<void>(req);
    } finally {
      UserStore.clear();
    }
  }

  /**
   * 刷新 Token
   * 当 Access Token 过期时调用此接口获取新的 Token
   */
  static async refreshToken(): Promise<string> {
    const req = new RequestConfig();
    req.path = '/auth/refresh';
    req.method = 'POST';
    req.hasBody = true;
    
    // 发送 Refresh Token 给后端
    const refreshToken = UserStore.getRefreshToken();
    console.log('=== Refreshing token ===');
    console.log('Refresh token available:', refreshToken.length > 0);
    
    if (!refreshToken || refreshToken.length === 0) {
      console.error('No refresh token available');
      throw new Error('No refresh token available');
    }
    
    req.body = JSON.stringify({ refreshToken });
    console.log('Sending refresh request...');
    
    try {
      const result = await HttpClient.request<RefreshTokenResponse>(req);
      console.log('Refresh response received');
      
      const newAccessToken = result.data?.accessToken || '';
      const newRefreshToken = result.data?.refreshToken || '';
      
      console.log('New access token length:', newAccessToken.length);
      console.log('New refresh token length:', newRefreshToken.length);
      
      if (newAccessToken.length > 0) {
        // 更新 Access Token 和 Refresh Token
        UserStore.setSession(newAccessToken, UserStore.getUserId(), newRefreshToken);
        console.log('Token refreshed successfully');
        return newAccessToken;
      } else {
        console.error('Invalid refresh token response: no access token');
        const error = new Error('Invalid refresh token response');
        throw error;
      }
    } catch (error) {
      console.error('Failed to refresh token:', error);
      // 刷新失败,清除用户会话
      UserStore.clear();
      const err = error instanceof Error ? error : new Error('Token refresh failed');
      throw err;
    }
  }
}
