import preferences from '@ohos.data.preferences';
import Context from '@ohos.app.ability.common';
import { CartItem } from './CartRepository';
import { FeaturedListCard } from '../../home/data/HomeRepository';
import { CartRecommendationItem, CartRemoteData, CartRemoteItem, CartRemoteRepository } from './CartRemoteRepository';
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

class RecommendationDTO {
  id: string = '';
  skuId: string = '';
  name: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  priceText: string = '';
}

export class CartStorage {
  private static readonly prefName: string = 'teabuy_cache';
  private static readonly cartKey: string = 'cartItems';
  private static readonly recommendKey: string = 'cartRecommendations';
  private static readonly recommendUpdatedAtKey: string = 'cartRecommendationsUpdatedAt';
  private static readonly recommendTtlMs: number = 10 * 60 * 1000;
  private static readonly recommendMinRefreshIntervalMs: number = 60 * 1000;
  private static prefs: preferences.Preferences | null = null;
  private static appContext: Context | null = null;
  private static bootstrapped: boolean = false;
  private static remoteIdBySku: Map<string, string> = new Map();
  private static recommendFetchInFlight: boolean = false;
  private static lastRecommendFetchAt: number = 0;

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
    const cachedRecommendations = await CartStorage.loadRecommendations(context);
    CartStorage.setRecommendationStorage(cachedRecommendations);
    if (UserStore.isLoggedIn()) {
      await CartStorage.syncRemote(context);
    }
  }

  static async syncRemote(context: Context): Promise<void> {
    try {
      const cached = await CartStorage.load(context);
      const remote = await CartRemoteRepository.getCart();
      CartStorage.updateRemoteIndex(remote);
      await CartStorage.updateRecommendationsCache(context, remote.recommendations || []);
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
      await CartStorage.updateRecommendationsCache(context, refreshed.recommendations || []);
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
      void CartStorage.invalidateRecommendations(CartStorage.appContext);
      void CartStorage.refreshRecommendations(CartStorage.appContext, true);
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

  private static setRecommendationStorage(items: FeaturedListCard[]): void {
    AppStorage.setOrCreate('cartRecommendations', items);
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

  private static toRecommendationDTO(items: FeaturedListCard[]): RecommendationDTO[] {
    return items.map(item => {
      const dto = new RecommendationDTO();
      dto.id = item.id || '';
      dto.skuId = item.skuId || '';
      dto.name = item.name || '';
      dto.subtitle = item.subtitle || '';
      dto.imageUrl = item.imageUrl || '';
      dto.priceText = item.priceText || '';
      return dto;
    });
  }

  private static fromRecommendationDTO(items: RecommendationDTO[]): FeaturedListCard[] {
    return items.map(dto => {
      const card = new FeaturedListCard();
      card.id = dto.id;
      card.skuId = dto.skuId;
      card.name = dto.name;
      card.subtitle = dto.subtitle;
      card.imageUrl = dto.imageUrl;
      card.priceText = dto.priceText;
      return card;
    });
  }

  private static mapRecommendations(items: CartRecommendationItem[]): FeaturedListCard[] {
    return items.map(item => {
      const card = new FeaturedListCard();
      card.id = item.id;
      card.name = item.name;
      card.subtitle = item.subtitle;
      card.imageUrl = item.imageUrl;
      card.priceText = item.priceText;
      card.skuId = item.defaultSkuId;
      return card;
    });
  }

  private static async updateRecommendationsCache(context: Context, items: CartRecommendationItem[]): Promise<void> {
    const mapped = CartStorage.mapRecommendations(items);
    CartStorage.setRecommendationStorage(mapped);
    await CartStorage.saveRecommendations(context, mapped);
    await CartStorage.saveRecommendationsUpdatedAt(context, Date.now());
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

  static async loadRecommendations(context: Context): Promise<FeaturedListCard[]> {
    try {
      const prefs = await CartStorage.getPrefs(context);
      const raw = await prefs.get(CartStorage.recommendKey, '') as string;
      if (!raw || raw.length === 0) {
        return [];
      }
      const parsed = JSON.parse(raw) as RecommendationDTO[];
      return CartStorage.fromRecommendationDTO(parsed);
    } catch (error) {
      console.error('Failed to load recommendation cache:', error);
      return [];
    }
  }

  private static async loadRecommendationsUpdatedAt(context: Context): Promise<number> {
    try {
      const prefs = await CartStorage.getPrefs(context);
      const value = await prefs.get(CartStorage.recommendUpdatedAtKey, 0) as number;
      return typeof value === 'number' ? value : 0;
    } catch (error) {
      console.error('Failed to load recommendation updatedAt:', error);
      return 0;
    }
  }

  private static async saveRecommendationsUpdatedAt(context: Context, value: number): Promise<void> {
    try {
      const prefs = await CartStorage.getPrefs(context);
      await prefs.put(CartStorage.recommendUpdatedAtKey, value);
      await prefs.flush();
    } catch (error) {
      console.error('Failed to save recommendation updatedAt:', error);
    }
  }

  static async invalidateRecommendations(context: Context): Promise<void> {
    await CartStorage.saveRecommendationsUpdatedAt(context, 0);
  }

  private static async shouldRefreshRecommendations(context: Context, force: boolean): Promise<boolean> {
    if (CartStorage.recommendFetchInFlight) {
      return false;
    }
    const now = Date.now();
    if (now - CartStorage.lastRecommendFetchAt < CartStorage.recommendMinRefreshIntervalMs) {
      return false;
    }
    if (force) {
      return true;
    }
    const updatedAt = await CartStorage.loadRecommendationsUpdatedAt(context);
    if (updatedAt <= 0) {
      return true;
    }
    return now - updatedAt > CartStorage.recommendTtlMs;
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

  static async saveRecommendations(context: Context, items: FeaturedListCard[]): Promise<void> {
    try {
      const prefs = await CartStorage.getPrefs(context);
      const dto = CartStorage.toRecommendationDTO(items);
      await prefs.put(CartStorage.recommendKey, JSON.stringify(dto));
      await prefs.flush();
    } catch (error) {
      console.error('Failed to save recommendation cache:', error);
    }
  }

  static async refreshRecommendations(context: Context, force: boolean = false): Promise<void> {
    const shouldRefresh = await CartStorage.shouldRefreshRecommendations(context, force);
    if (!shouldRefresh) {
      return;
    }
    CartStorage.recommendFetchInFlight = true;
    CartStorage.lastRecommendFetchAt = Date.now();
    try {
      const remote = await CartRemoteRepository.getCart();
      CartStorage.updateRemoteIndex(remote);
      await CartStorage.updateRecommendationsCache(context, remote.recommendations || []);
    } catch (error) {
      console.error('Failed to refresh cart recommendations:', error);
    } finally {
      CartStorage.recommendFetchInFlight = false;
    }
  }
}
