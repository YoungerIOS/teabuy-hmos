import { HttpClient } from '../../../core/network/HttpClient';
import { createGetRequest } from '../../../core/network/Interceptors';
import { RouteParams } from '../../../router/RouteParams';

export class FeaturedListCard {
  skuId?: string = '';
  id?: string = '';
  title?: string = '';
  name?: string = '';
  subtitle: string = '';
  image?: string = '';
  imageUrl?: string = '';
  price?: string = '';
  priceText?: string = '';
  marketPrice?: string = '';
  buttonText?: string = '';
  marketingText?: string = '';
  soldCountText?: string = '';
  badgePrimary?: string = '';
  badgeSecondary?: string = '';
  linkValue?: string = '';
  sort?: number = 0;
}

export class ProductItem {
  id: string = '';
  name: string = '';
  subtitle: string = '';
  categoryId: string = '';
  imageUrl: string = '';
  defaultSkuId: string = '';
  priceCent: number = 0;
  priceText: string = '';
  marketPriceCent: number = 0;
  soldCount: number = 0;
  badgePrimary: string = '';
  badgeSecondary: string = '';
  status: string = '';
  stock: number = 0;
}

export class ProductItemHelper {
  static toFeaturedListCard(item: ProductItem): FeaturedListCard {
    const card = new FeaturedListCard();
    card.id = item.id;
    card.name = item.name;
    card.subtitle = item.subtitle;
    card.imageUrl = item.imageUrl;
    card.skuId = item.defaultSkuId;
    card.priceText = item.priceText;
    card.soldCountText = `${item.soldCount}人买过`;
    card.badgePrimary = item.badgePrimary;
    card.badgeSecondary = item.badgeSecondary;
    return card;
  }
}

export class ProductSkuItem {
  id: string = '';
  name: string = '';
  priceCent: number = 0;
  priceText: string = '';
  stock: number = 0;
}

export class ProductRecommendationItem {
  id: string = '';
  name: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  priceCent: number = 0;
}

export class ProductDetailData {
  id: string = '';
  name: string = '';
  subtitle: string = '';
  description: string = '';
  status: string = '';
  marketPriceCent: number = 0;
  soldCount: number = 0;
  badgePrimary: string = '';
  badgeSecondary: string = '';
  mainImageUrl: string = '';
  images: string[] = [];
  serviceTags: string[] = [];
  skus: ProductSkuItem[] = [];
  recommendations: ProductRecommendationItem[] = [];
}

export class HealthData {
  status: string = '';
}

export class HomeReviewTopicData {
  title: string = '';
  imageUrl: string = '';
  sort: number = 0;
}

export class HomeNewTeaItemData {
  title: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  wantsText: string = '';
  linkType: string = '';
  linkValue: string = '';
  sort: number = 0;
}

export class HomeFeaturedTabData {
  key: string = '';
  title: string = '';
  sort: number = 0;
}

export class HomeFeaturedPriceData {
  currencySymbol: string = '￥';
  amount: string = '';
  unit: string = '';
}

export class HomeFeaturedListCardData {
  name: string = '';
  subtitle: string = '';
  marketingText: string = '';
  soldCountText: string = '';
  badgePrimary: string = '';
  badgeSecondary: string = '';
  price: HomeFeaturedPriceData = new HomeFeaturedPriceData();
  imageUrl: string = '';
  linkType: string = '';
  linkValue: string = '';
  sort: number = 0;
}

export class HomeFeaturedItemData {
  title: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  tagText: string = '';
  priceText: string = '';
  cards: HomeFeaturedListCardData[] = [];
  linkType: string = '';
  linkValue: string = '';
  sort: number = 0;
}

export class HomeFeaturedSectionData {
  key: string = '';
  title: string = '';
  subtitle: string = '';
  layout: string = '';
  items: HomeFeaturedItemData[] = [];
  sort: number = 0;
}

export class HomePromoSectionData {
  key: string = '';
  title: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  leftImageUrl: string = '';
  rightImageUrl: string = '';
  badgeText: string = '';
  priceLabel: string = '';
  priceText: string = '';
  ctaText: string = '';
  linkType: string = '';
  linkValue: string = '';
  sort: number = 0;
}

export class HomeModulePayloadData {
  topics: HomeReviewTopicData[] = [];
  items: HomeNewTeaItemData[] = [];
  notice: string = '';
  tabs: HomeFeaturedTabData[] = [];
  activeTab: string = '';
  sections: Array<HomeFeaturedSectionData | HomePromoSectionData> = [];
  updatedAt: number = 0;
}

export class HomeModuleData {
  key: string = '';
  title: string = '';
  payload: HomeModulePayloadData = new HomeModulePayloadData();
}

export class HomeBannerData {
  imageUrl: string = '';
  linkType: string = '';
  linkValue: string = '';
  sort: number = 0;
}

export class HomeData {
  unreadCount: number = 0;
  modules: HomeModuleData[] = [];
  banners: HomeBannerData[] = [];
}

export class CategoryItem {
  key: string = '';
  name: string = '';
  iconUrl: string = '';
  linkType: string = '';
  linkValue: string = '';
  sort: number = 0;
}

export class CategoryData {
  title: string = '';
  items: CategoryItem[] = [];
  updatedAt: number = 0;
}

export class NavigationResolveData {
  route: string = '';
  params: RouteParams = new RouteParams();
}

export class ProductListData {
  items: ProductItem[] = [];
  total: number = 0;
  page: number = 1;
  pageSize: number = 20;
}

export interface ProductQueryParams {
  keyword?: string;
  categoryKey?: string;
  activityKey?: string;
  topicKey?: string;
  page?: number;
  pageSize?: number;
}

export class HomeRepository {
  static async getHealth(): Promise<HealthData> {
    const req = createGetRequest('/health');
    const result = await HttpClient.request<HealthData>(req);
    return result.data;
  }

  static async getHealthDb(): Promise<HealthData> {
    const req = createGetRequest('/health/db');
    const result = await HttpClient.request<HealthData>(req);
    return result.data;
  }

  static async getHome(): Promise<HomeData> {
    const req = createGetRequest('/home');
    const result = await HttpClient.request<HomeData>(req);
    return result.data;
  }

  static async getCategories(): Promise<CategoryData> {
    const req = createGetRequest('/home/categories');
    const result = await HttpClient.request<CategoryData>(req);
    return result.data;
  }

  static async resolveNavigation(linkType: string, linkValue?: string): Promise<NavigationResolveData> {
    let path = `/navigation/resolve?linkType=${linkType}`;
    if (linkValue) {
      path += `&linkValue=${encodeURIComponent(linkValue)}`;
    }
    const req = createGetRequest(path);
    const result = await HttpClient.request<NavigationResolveData>(req);
    return result.data;
  }

  static async getProducts(params?: ProductQueryParams): Promise<ProductListData> {
    let path = '/catalog/products?';
    const queryParams: string[] = [];
    
    if (params?.keyword) {
      queryParams.push(`keyword=${encodeURIComponent(params.keyword)}`);
    }
    if (params?.categoryKey) {
      queryParams.push(`categoryKey=${encodeURIComponent(params.categoryKey)}`);
    }
    if (params?.activityKey) {
      queryParams.push(`activityKey=${encodeURIComponent(params.activityKey)}`);
    }
    if (params?.topicKey) {
      queryParams.push(`topicKey=${encodeURIComponent(params.topicKey)}`);
    }
    if (params?.page) {
      queryParams.push(`page=${params.page}`);
    } else {
      queryParams.push('page=1');
    }
    if (params?.pageSize) {
      queryParams.push(`pageSize=${params.pageSize}`);
    } else {
      queryParams.push('pageSize=20');
    }
    
    path += queryParams.join('&');
    const req = createGetRequest(path);
    const result = await HttpClient.request<ProductListData>(req);
    return result.data;
  }

  static async getProductDetail(productId: string): Promise<ProductDetailData> {
    const req = createGetRequest(`/catalog/products/${productId}`);
    const result = await HttpClient.request<ProductDetailData>(req);
    return result.data;
  }
}
