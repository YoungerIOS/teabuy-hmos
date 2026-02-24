import { HttpClient } from '../../../core/network/HttpClient';
import { createGetRequest } from '../../../core/network/Interceptors';

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

export class HomeModulePayloadData {
  topics: HomeReviewTopicData[] = [];
  items: HomeNewTeaItemData[] = [];
  notice: string = '';
  tabs: HomeFeaturedTabData[] = [];
  activeTab: string = '';
  sections: HomeFeaturedSectionData[] = [];
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
}
