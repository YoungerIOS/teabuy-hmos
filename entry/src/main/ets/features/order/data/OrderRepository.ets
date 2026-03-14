import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';

export class OrderPreviewItem {
  cartItemId: string = '';
  skuId: string = '';
  productName: string = '';
  skuName: string = '';
  imageUrl: string = '';
  quantity: number = 0;
  priceCent: number = 0;
  subtotalCent: number = 0;
  subtotalText: string = '';
}

export class OrderPreviewData {
  items: OrderPreviewItem[] = [];
  subtotalCent: number = 0;
  shippingCent: number = 0;
  discountCent: number = 0;
  payableCent: number = 0;
  addressRequired: boolean = false;
}

export class OrderCreateResult {
  orderNo: string = '';
  status: string = '';
  totalCent: number = 0;
  paymentRequired: boolean = true;
  idempotent: boolean = false;
}

export class OrderDetailItem {
  skuId: string = '';
  productName: string = '';
  skuName: string = '';
  imageUrl: string = '';
  quantity: number = 0;
  priceCent: number = 0;
}

export class OrderPriceSnapshot {
  subtotalCent: number = 0;
  shippingCent: number = 0;
  discountCent: number = 0;
  payableCent: number = 0;
}

export class OrderDetailData {
  orderNo: string = '';
  status: string = '';
  totalCent: number = 0;
  address: Record<string, string> = {};
  priceSnapshot: OrderPriceSnapshot = new OrderPriceSnapshot();
  items: OrderDetailItem[] = [];
  canCancel: boolean = false;
  canPay: boolean = false;
  canRefund: boolean = false;
  canConfirmDelivery: boolean = false;
}

export class OrderListItem {
  orderNo: string = '';
  status: string = '';
  totalCent: number = 0;
  createdAt: string = '';
  updatedAt: string = '';
}

export class OrderListData {
  page: number = 1;
  pageSize: number = 20;
  items: OrderListItem[] = [];
}

export class OrderTabSummaryItem {
  status: string = '';
  count: number = 0;
}

export class OrderTabSummaryData {
  items: OrderTabSummaryItem[] = [];
  totalCount: number = 0;
}

export class OrderRepository {
  private static readonly TAB_SUMMARY_TTL_MS: number = 30000;
  private static tabSummaryCache: OrderTabSummaryData | null = null;
  private static tabSummaryCacheAt: number = 0;

  static getCachedPendingCount(): number {
    const cached = OrderRepository.getCachedTabSummary();
    if (!cached) {
      return 0;
    }
    return OrderRepository.countPendingFromSummary(cached);
  }

  private static getCachedTabSummary(): OrderTabSummaryData | null {
    if (!OrderRepository.tabSummaryCache) {
      return null;
    }
    const now = Date.now();
    if (now - OrderRepository.tabSummaryCacheAt > OrderRepository.TAB_SUMMARY_TTL_MS) {
      return null;
    }
    return OrderRepository.tabSummaryCache;
  }

  private static countPendingFromSummary(summary: OrderTabSummaryData): number {
    let total = 0;
    if (summary.items && summary.items.length > 0) {
      for (let i = 0; i < summary.items.length; i++) {
        const item = summary.items[i];
        if (item.status !== 'COMPLETED') {
          total += item.count;
        }
      }
    }
    return total;
  }

  static async preview(cartItemIds: string[]): Promise<OrderPreviewData> {
    const req = new RequestConfig();
    req.path = '/orders/preview';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ cartItemIds });
    const result = await HttpClient.request<OrderPreviewData>(req);
    return result.data || new OrderPreviewData();
  }

  static async createOrder(cartItemIds: string[], addressId: string): Promise<OrderCreateResult> {
    const req = new RequestConfig();
    req.path = '/orders';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ cartItemIds, addressId });
    const result = await HttpClient.request<OrderCreateResult>(req);
    return result.data || new OrderCreateResult();
  }

  static async getDetail(orderNo: string): Promise<OrderDetailData> {
    const req = new RequestConfig();
    req.path = `/orders/${orderNo}`;
    req.method = 'GET';
    const result = await HttpClient.request<OrderDetailData>(req);
    return result.data || new OrderDetailData();
  }

  static async listOrders(status: string, page: number = 1, pageSize: number = 20): Promise<OrderListData> {
    const query: string[] = [];
    if (status && status.length > 0) {
      query.push(`status=${encodeURIComponent(status)}`);
    }
    query.push(`page=${page}`);
    query.push(`page_size=${pageSize}`);
    const req = new RequestConfig();
    req.path = `/orders?${query.join('&')}`;
    req.method = 'GET';
    const result = await HttpClient.request<OrderListData>(req);
    return result.data || new OrderListData();
  }

  static async getTabSummary(): Promise<OrderTabSummaryData> {
    const req = new RequestConfig();
    req.path = '/orders/tab-summary';
    req.method = 'GET';
    const result = await HttpClient.request<OrderTabSummaryData>(req);
    const summary = result.data || new OrderTabSummaryData();
    OrderRepository.tabSummaryCache = summary;
    OrderRepository.tabSummaryCacheAt = Date.now();
    return summary;
  }
}
