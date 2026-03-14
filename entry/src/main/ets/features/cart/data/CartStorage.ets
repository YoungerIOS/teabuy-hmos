import preferences from '@ohos.data.preferences';
import Context from '@ohos.app.ability.common';
import { CartItem } from './CartRepository';
import { FeaturedListCard } from '../../home/data/HomeRepository';
import { CartRemoteData, CartRemoteItem, CartRemoteRepository } from './CartRemoteRepository';
import { UserStore } from '../../../core/store/UserStore';

class ProductDTO {
  id: string = '';
  skuId: string = '';
  name: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  priceText: string = '';
  soldCountText: string = '';
  badgePrimary: string = '';
  badgeSecondary: string = '';
}

class CartItemDTO {
  id: string = '';
  quantity: number = 0;
  selected: boolean = false;
  product: ProductDTO = new ProductDTO();
}

export class CartStorage {
  private static readonly prefName: string = 'teabuy_cache';
  private static readonly cartKey: string = 'cartItems';
  private static prefs: preferences.Preferences | null = null;
  private static appContext: Context | null = null;
  private static bootstrapped: boolean = false;
  private static remoteIdBySku: Map<string, string> = new Map();

  static async bootstrap(context: Context): Promise<void> {
    if (CartStorage.bootstrapped) {
      return;
    }
    CartStorage.bootstrapped = true;
    CartStorage.appContext = context;
    const cached = await CartStorage.load(context);
    if (cached.length > 0) {
      CartStorage.setAppStorage(cached);
    }
    if (UserStore.isLoggedIn()) {
      await CartStorage.syncRemote(context);
    }
  }

  static async syncRemote(context: Context): Promise<void> {
    try {
      const cached = await CartStorage.load(context);
      const remote = await CartRemoteRepository.getCart();
      CartStorage.updateRemoteIndex(remote);
      if (cached.length === 0) {
        const mapped = CartStorage.fromRemote(remote);
        CartStorage.setAppStorage(mapped);
        await CartStorage.save(context, mapped);
        return;
      }

      if (remote.items.length === 0) {
        CartStorage.setAppStorage(cached);
        await CartStorage.save(context, cached);
        return;
      }

      const remoteItemBySku = new Map<string, CartRemoteItem>();
      for (let i = 0; i < remote.items.length; i++) {
        const item = remote.items[i];
        if (item.skuId && item.skuId.length > 0) {
          remoteItemBySku.set(item.skuId, item);
        }
      }

      const tasks: Promise<void>[] = [];
      for (let i = 0; i < cached.length; i++) {
        const localItem = cached[i];
        const skuId = localItem.product.skuId || '';
        if (skuId.length === 0) {
          continue;
        }
        const remoteItem = remoteItemBySku.get(skuId);
        if (remoteItem) {
          const needQty = remoteItem.quantity !== localItem.quantity;
          const needSelect = remoteItem.selected !== localItem.selected;
          if (needQty || needSelect) {
            const qty = localItem.quantity > 0 ? localItem.quantity : remoteItem.quantity;
            tasks.push(CartRemoteRepository.updateItem(remoteItem.id, qty, needSelect ? localItem.selected : undefined));
          }
        } else {
          tasks.push(CartRemoteRepository.addItem(skuId, localItem.quantity));
        }
      }

      if (tasks.length > 0) {
        await Promise.all(tasks);
      }

      const refreshed = await CartRemoteRepository.getCart();
      CartStorage.updateRemoteIndex(refreshed);
      const mapped = CartStorage.fromRemote(refreshed);
      CartStorage.setAppStorage(mapped);
      await CartStorage.save(context, mapped);
    } catch (error) {
      console.error('Failed to sync remote cart:', error);
    }
  }

  static update(items: CartItem[]): void {
    const normalized = CartStorage.clone(items);
    CartStorage.setAppStorage(normalized);
    if (CartStorage.appContext) {
      void CartStorage.save(CartStorage.appContext, normalized);
    }
  }

  static updateRemoteIndex(remote: CartRemoteData): void {
    CartStorage.remoteIdBySku = new Map();
    for (let i = 0; i < remote.items.length; i++) {
      const item = remote.items[i];
      if (item.skuId && item.skuId.length > 0) {
        CartStorage.remoteIdBySku.set(item.skuId, item.id);
      }
    }
  }

  static getRemoteIdBySku(skuId: string): string {
    return CartStorage.remoteIdBySku.get(skuId) || '';
  }

  static async ensureRemoteId(skuId: string): Promise<string> {
    if (skuId.length === 0) {
      return '';
    }
    const cached = CartStorage.getRemoteIdBySku(skuId);
    if (cached.length > 0) {
      return cached;
    }
    try {
      const remote = await CartRemoteRepository.getCart();
      CartStorage.updateRemoteIndex(remote);
      return CartStorage.getRemoteIdBySku(skuId);
    } catch (error) {
      console.error('Failed to refresh remote cart index:', error);
      return '';
    }
  }

  private static setAppStorage(items: CartItem[]): void {
    AppStorage.setOrCreate('cartItems', items);
  }

  private static clone(items: CartItem[]): CartItem[] {
    return items.map(item => new CartItem(item.id, item.product, item.quantity, item.selected));
  }

  private static async getPrefs(context: Context): Promise<preferences.Preferences> {
    if (CartStorage.prefs) {
      return CartStorage.prefs;
    }
    CartStorage.prefs = await preferences.getPreferences(context, CartStorage.prefName);
    return CartStorage.prefs;
  }

  private static toDTO(items: CartItem[]): CartItemDTO[] {
    return items.map(item => {
      const dto = new CartItemDTO();
      dto.id = item.id;
      dto.quantity = item.quantity;
      dto.selected = item.selected;
      const product = new ProductDTO();
      product.id = item.product.id || '';
      product.skuId = item.product.skuId || '';
      product.name = item.product.name || '';
      product.subtitle = item.product.subtitle || '';
      product.imageUrl = item.product.imageUrl || '';
      product.priceText = item.product.priceText || '';
      product.soldCountText = item.product.soldCountText || '';
      product.badgePrimary = item.product.badgePrimary || '';
      product.badgeSecondary = item.product.badgeSecondary || '';
      dto.product = product;
      return dto;
    });
  }

  private static fromDTO(items: CartItemDTO[]): CartItem[] {
    return items.map(dto => {
      const card = new FeaturedListCard();
      card.id = dto.product.id;
      card.skuId = dto.product.skuId;
      card.name = dto.product.name;
      card.subtitle = dto.product.subtitle;
      card.imageUrl = dto.product.imageUrl;
      card.priceText = dto.product.priceText;
      card.soldCountText = dto.product.soldCountText;
      card.badgePrimary = dto.product.badgePrimary;
      card.badgeSecondary = dto.product.badgeSecondary;
      return new CartItem(dto.id, card, dto.quantity, dto.selected);
    });
  }

  static fromRemote(remote: CartRemoteData): CartItem[] {
    return remote.items.map(item => {
      const card = new FeaturedListCard();
      card.id = item.skuId;
      card.skuId = item.skuId;
      card.name = item.productName;
      card.subtitle = item.subtitle;
      card.imageUrl = item.imageUrl;
      card.priceText = item.priceText.length > 0 ? item.priceText : `￥${(item.unitPriceCent / 100).toFixed(2)}`;
      return new CartItem(item.id, card, item.quantity, item.selected);
    });
  }

  static async load(context: Context): Promise<CartItem[]> {
    try {
      const prefs = await CartStorage.getPrefs(context);
      const raw = await prefs.get(CartStorage.cartKey, '') as string;
      if (!raw || raw.length === 0) {
        return [];
      }
      const parsed = JSON.parse(raw) as CartItemDTO[];
      return CartStorage.fromDTO(parsed);
    } catch (error) {
      console.error('Failed to load cart cache:', error);
      return [];
    }
  }

  static async save(context: Context, items: CartItem[]): Promise<void> {
    try {
      const prefs = await CartStorage.getPrefs(context);
      const dto = CartStorage.toDTO(items);
      await prefs.put(CartStorage.cartKey, JSON.stringify(dto));
      await prefs.flush();
    } catch (error) {
      console.error('Failed to save cart cache:', error);
    }
  }
}
