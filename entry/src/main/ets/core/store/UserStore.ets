export class UserStore {
  private static accessToken: string = '';
  private static refreshToken: string = '';
  private static userId: string = '';

  static setSession(accessToken: string, userId: string, refreshToken?: string): void {
    UserStore.accessToken = accessToken || '';
    UserStore.userId = userId || '';
    if (refreshToken) {
      UserStore.refreshToken = refreshToken;
    }
  }

  static setAccessToken(accessToken: string): void {
    UserStore.accessToken = accessToken || '';
  }

  static clear(): void {
    UserStore.accessToken = '';
    UserStore.refreshToken = '';
    UserStore.userId = '';
  }

  static getAccessToken(): string {
    return UserStore.accessToken || '';
  }

  static getRefreshToken(): string {
    return UserStore.refreshToken || '';
  }

  static getUserId(): string {
    return UserStore.userId || '';
  }

  static isLoggedIn(): boolean {
    return UserStore.accessToken != null && UserStore.accessToken.length > 0;
  }
}
