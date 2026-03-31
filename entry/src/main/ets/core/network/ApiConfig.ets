export class ApiConfig {
  // Replace with your deployed Vercel backend domain.
  static readonly baseUrl: string = 'https://teabuy-backend.vercel.app';
  static readonly apiPrefix: string = '/api/v1';
  // Fallback token for manual testing. Keep empty in normal development.
  static readonly authToken: string = '';
  static readonly debugUsername: string = 'test001';
  static readonly debugPassword: string = '12345678';
  static readonly enableBackendProbe: boolean = false;
  static readonly timeoutMs: number = 15000;
}
