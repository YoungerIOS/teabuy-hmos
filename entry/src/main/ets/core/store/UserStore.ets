export class UserStore {
  private static token: string = '';
  private static userId: string = '';

  static setSession(token: string, userId: string): void {
    UserStore.token = token;
    UserStore.userId = userId;
  }

  static clear(): void {
    UserStore.token = '';
    UserStore.userId = '';
  }

  static getToken(): string {
    return UserStore.token;
  }

  static isLoggedIn(): boolean {
    return UserStore.token.length > 0;
  }
}
