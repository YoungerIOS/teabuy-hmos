import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';

export class NotificationItem {
  id: string = '';
  title: string = '';
  content: string = '';
  isRead: boolean = false;
  readAt: string = '';
  createdAt: string = '';
  updatedAt: string = '';
  linkType: string = '';
  linkValue: string = '';
  type: string = '';
  priority: number = 0;
}

export class NotificationListData {
  items: NotificationItem[] = [];
  nextCursor: string = '';
  unreadCount: number = 0;
}

export class NotificationUnreadData {
  unreadCount: number = 0;
}

export class NotificationSummaryData {
  unreadCount: number = 0;
  latestNotificationAt: string = '';
  serverTime: string = '';
}

export class NotificationReadAllData {
  success: boolean = false;
  unreadCount: number = 0;
}

export class NotificationReadOneData {
  success: boolean = false;
  unreadCount: number = 0;
}

export class NotificationRepository {
  static async getUnreadCount(): Promise<number> {
    const req = new RequestConfig();
    req.path = '/notifications/unread-count';
    req.method = 'GET';
    const result = await HttpClient.request<NotificationUnreadData>(req);
    const data = result.data || new NotificationUnreadData();
    return data.unreadCount > 0 ? data.unreadCount : 0;
  }

  static async getSummary(): Promise<NotificationSummaryData> {
    const req = new RequestConfig();
    req.path = '/notifications/summary';
    req.method = 'GET';
    const result = await HttpClient.request<NotificationSummaryData>(req);
    const data = result.data || new NotificationSummaryData();
    data.unreadCount = data.unreadCount > 0 ? data.unreadCount : 0;
    return data;
  }

  static async readAll(): Promise<boolean> {
    const req = new RequestConfig();
    req.path = '/notifications/read-all';
    req.method = 'POST';
    const result = await HttpClient.request<NotificationReadAllData>(req);
    const data = result.data || new NotificationReadAllData();
    return data.success;
  }

  static async readBatch(ids: string[]): Promise<NotificationReadAllData> {
    const req = new RequestConfig();
    req.path = '/notifications/read-batch';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ ids });
    const result = await HttpClient.request<NotificationReadAllData>(req);
    return result.data || new NotificationReadAllData();
  }

  static async markRead(notificationId: string, read: boolean = true): Promise<NotificationReadOneData> {
    if (!read) {
      return new NotificationReadOneData();
    }
    const batch = await NotificationRepository.readBatch([notificationId]);
    const one = new NotificationReadOneData();
    one.success = batch.success;
    one.unreadCount = batch.unreadCount;
    return one;
  }

  static async getOne(notificationId: string): Promise<NotificationItem> {
    const req = new RequestConfig();
    req.path = `/notifications/${notificationId}`;
    req.method = 'GET';
    const result = await HttpClient.request<NotificationItem>(req);
    return result.data || new NotificationItem();
  }

  static async list(cursor: string = '', limit: number = 20): Promise<NotificationListData> {
    const query: string[] = [];
    if (cursor.length > 0) {
      query.push(`cursor=${encodeURIComponent(cursor)}`);
    }
    query.push(`limit=${limit}`);
    const req = new RequestConfig();
    req.path = `/notifications?${query.join('&')}`;
    req.method = 'GET';
    const result = await HttpClient.request<NotificationListData>(req);
    const data = result.data || new NotificationListData();
    data.unreadCount = data.unreadCount > 0 ? data.unreadCount : 0;
    return data;
  }
}
