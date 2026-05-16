import { Injectable, signal, computed } from '@angular/core';

interface User {
  id: number;
  username: string;
  email: string | null;
  role: string;
  is_active: boolean;
  is_admin: boolean;
}

interface AuthResponse {
  success: boolean;
  message: string;
  token?: string;
  user?: User;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private TOKEN_KEY = 'lrg_bot_token';
  private USER_KEY = 'lrg_bot_user';
  private LOGIN_PATH = '/admin/login';
  
  private _token = signal<string | null>(null);
  private _user = signal<User | null>(null);
  
  // Computed signals for reactive state
  isLoggedIn = computed(() => !!this._token());
  isAdmin = computed(() => this._user()?.is_admin ?? false);
  currentUser = computed(() => this._user());
  
  constructor() {
    this.installFetchInterceptor();
    // Load from sessionStorage on init
    this.loadFromStorage();
  }

  private installFetchInterceptor(): void {
    const globalWindow = window as typeof window & { __lrgAuthFetchInstalled?: boolean };
    if (globalWindow.__lrgAuthFetchInstalled) {
      return;
    }

    const originalFetch = window.fetch.bind(window);
    globalWindow.__lrgAuthFetchInstalled = true;

    window.fetch = async (input: RequestInfo | URL, init?: RequestInit): Promise<Response> => {
      const requestUrl = typeof input === 'string'
        ? input
        : input instanceof URL
          ? input.toString()
          : input.url;

      const parsedUrl = new URL(requestUrl, window.location.origin);
      const isSameOrigin = parsedUrl.origin === window.location.origin;
      const isApiRequest = isSameOrigin && parsedUrl.pathname.startsWith('/api/');
      const isPublicAuthRequest = parsedUrl.pathname === '/api/v1/auth/login' || parsedUrl.pathname === '/api/v1/auth/register';
      const token = this._token();

      let nextInit = init;
      if (isApiRequest && !isPublicAuthRequest && token) {
        const headers = new Headers(init?.headers ?? {});
        if (!headers.has('Authorization')) {
          headers.set('Authorization', `Bearer ${token}`);
        }
        nextInit = { ...init, headers };
      }

      const response = await originalFetch(input, nextInit);

      if (isApiRequest && !isPublicAuthRequest && response.status === 401) {
        this.clearStorage();
        if (window.location.pathname !== this.LOGIN_PATH) {
          window.location.assign(this.LOGIN_PATH);
        }
      }

      return response;
    };
  }
  
  private loadFromStorage(): void {
    const token = sessionStorage.getItem(this.TOKEN_KEY);
    const userStr = sessionStorage.getItem(this.USER_KEY);
    
    if (token) {
      this._token.set(token);
    }
    if (userStr) {
      try {
        this._user.set(JSON.parse(userStr));
      } catch {
        console.error('Failed to parse stored user');
      }
    }
  }
  
  private saveToStorage(token: string, user: User): void {
    sessionStorage.setItem(this.TOKEN_KEY, token);
    sessionStorage.setItem(this.USER_KEY, JSON.stringify(user));
    this._token.set(token);
    this._user.set(user);
  }
  
  private clearStorage(): void {
    sessionStorage.removeItem(this.TOKEN_KEY);
    sessionStorage.removeItem(this.USER_KEY);
    this._token.set(null);
    this._user.set(null);
  }
  
  getToken(): string | null {
    return this._token();
  }
  
  getAuthHeaders(): Record<string, string> {
    const token = this._token();
    if (token) {
      return { 'Authorization': `Bearer ${token}` };
    }
    return {};
  }
  
  async login(username: string, password: string): Promise<AuthResponse> {
    try {
      const response = await fetch('/api/v1/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
      });
      
      const data: AuthResponse = await response.json();
      
      if (data.success && data.token && data.user) {
        this.saveToStorage(data.token, data.user);
      }
      
      return data;
    } catch (error) {
      return { success: false, message: `Error: ${error}` };
    }
  }
  
  logout(): void {
    this.clearStorage();
  }
  
  async checkAuth(): Promise<boolean> {
    const token = this._token();
    if (!token) return false;
    
    try {
      const response = await fetch('/api/v1/auth/me', {
        headers: this.getAuthHeaders()
      });
      
      if (response.ok) {
        const data = await response.json();
        if (data.user) {
          this._user.set(data.user);
          sessionStorage.setItem(this.USER_KEY, JSON.stringify(data.user));
          return true;
        }
      }
      
      // Token invalid, clear it
      this.clearStorage();
      return false;
    } catch {
      return false;
    }
  }
}
