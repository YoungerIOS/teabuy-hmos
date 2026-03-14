import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';

export class CartRemoteItem {
  id: string = '';
  skuId: string = '';
  quantity: number = 0;
  selected: boolean = false;
  unitPriceCent: number = 0;
  subtotalCent: number = 0;
  subtotalText: string = '';
  priceText: string = '';
  productName: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  badges: string[] = [];
}

export class CartRecommendationItem {
  id: string = '';
  name: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  priceCent: number = 0;
  priceText: string = '';
  defaultSkuId: string = '';
}

export class CartRemoteData {
  items: CartRemoteItem[] = [];
  totalCent: number = 0;
  recommendations: CartRecommendationItem[] = [];
}

export class CartRemoteRepository {
  static async getCart(): Promise<CartRemoteData> {
    const req = new RequestConfig();
    req.path = '/cart';
    req.method = 'GET';
    const result = await HttpClient.request<CartRemoteData>(req);
    return result.data || new CartRemoteData();
  }

  static async addItem(skuId: string, quantity: number): Promise<void> {
    const req = new RequestConfig();
    req.path = '/cart/items';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ skuId, quantity });
    await HttpClient.request<void>(req);
  }

  static async updateItem(itemId: string, quantity: number, selected?: boolean): Promise<void> {
    const req = new RequestConfig();
    req.path = `/cart/items/${itemId}`;
    req.method = 'PATCH';
    req.hasBody = true;
    if (selected === undefined) {
      req.body = JSON.stringify({ quantity });
    } else {
      req.body = JSON.stringify({ quantity, selected });
    }
    await HttpClient.request<void>(req);
  }

  static async batchSelect(itemIds: string[], selected: boolean): Promise<void> {
    const req = new RequestConfig();
    req.path = '/cart/items/select';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ itemIds, selected });
    await HttpClient.request<void>(req);
  }

  static async deleteItem(itemId: string): Promise<void> {
    const req = new RequestConfig();
    req.path = `/cart/items/${itemId}`;
    req.method = 'DELETE';
    await HttpClient.request<void>(req);
  }
}
