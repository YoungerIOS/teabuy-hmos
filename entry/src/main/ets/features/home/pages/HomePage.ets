import { Colors } from '../../../core/ui/theme/Tokens';
import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { window } from '@kit.ArkUI';
import { ApiConfig } from '../../../core/network/ApiConfig';
import {
  HomeBannerData,
  HomeData,
  HomeFeaturedItemData,
  HomeFeaturedListCardData,
  HomeFeaturedSectionData,
  HomeFeaturedTabData,
  HomeModuleData,
  HomeNewTeaItemData,
  HomeRepository,
  HomeReviewTopicData
} from '../data/HomeRepository';
import { AuthRepository } from '../../auth/data/AuthRepository';
import { UserStore } from '../../../core/store/UserStore';
import { ReviewListPage } from '../../review/pages/ReviewListPage';

class ReviewTopic {
  title: string = '';
  imageUrl: string = '';
}

class NewTeaItem {
  title: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  wantsText: string = '';
}

class FeaturedTab {
  key: string = '';
  title: string = '';
  sort: number = 0;
}

class FeaturedListCard {
  name: string = '';
  subtitle: string = '';
  marketingText: string = '';
  soldCountText: string = '';
  badgePrimary: string = '';
  badgeSecondary: string = '';
  priceText: string = '';
  imageUrl: string = '';
  linkValue: string = '';
  sort: number = 0;
}

class FeaturedItem {
  title: string = '';
  subtitle: string = '';
  imageUrl: string = '';
  priceText: string = '';
  linkValue: string = '';
  sort: number = 0;
  cards: FeaturedListCard[] = [];
}

class FeaturedSection {
  key: string = '';
  title: string = '';
  subtitle: string = '';
  layout: string = '';
  sort: number = 0;
  items: FeaturedItem[] = [];
}

@Component
struct HomeTopSection {
  @Prop bannerModuleTitle: string = '推荐';
  @Prop bannerImages: string[] = [];
  @Prop showBanner: boolean = true;
  @Prop homeContentWidth: number = 375;
  @Prop featuredTabs: FeaturedTab[] = [];
  @Prop featuredBannerImages: string[] = [];
  @Link activeTopTab: number;
  @Link featuredActiveTabKey: string;
  @Link featuredBannerIndex: number;
  @State private activeBannerIndex: number = 0;
  @State private bannerLayerOffsetX: number = 0;

  private readonly topTabs: string[] = ['推荐', '精选'];

  private bannerCount(): number {
    return this.bannerImages.length;
  }

  private normalizeBannerIndex(index: number): number {
    const count = this.bannerCount();
    if (count <= 0) {
      return 0;
    }
    let next = index;
    while (next < 0) {
      next += count;
    }
    while (next >= count) {
      next -= count;
    }
    return next;
  }

  private bannerAt(offset: number): string {
    const count = this.bannerCount();
    if (count <= 0) {
      return '';
    }
    const targetIndex = this.normalizeBannerIndex(this.activeBannerIndex + offset);
    return this.bannerImages[targetIndex];
  }

  private slideDirection(nextIndex: number): number {
    const count = this.bannerCount();
    if (count <= 1) {
      return -1;
    }
    const current = this.normalizeBannerIndex(this.activeBannerIndex);
    const next = this.normalizeBannerIndex(nextIndex);
    const forward = (next - current + count) % count;
    const backward = (current - next + count) % count;
    if (forward === 0) {
      return -1;
    }
    return forward <= backward ? -1 : 1;
  }

  private topSectionHeight(): number {
    return this.showBanner ? 290 : this.featuredScale(336);
  }

  private featuredScale(value: number): number {
    return value * this.homeContentWidth / 375;
  }

  private featuredMainLeft(): number {
    return this.featuredScale(17);
  }

  private featuredMainWidth(): number {
    return this.featuredScale(340);
  }

  private featuredBannerHeight(): number {
    return this.featuredMainWidth() * (149 / 340);
  }

  private featuredTabsDisplay(): FeaturedTab[] {
    const tabs: FeaturedTab[] = [];
    for (let i = 0; i < this.featuredTabs.length && i < 5; i++) {
      tabs.push(this.featuredTabs[i]);
    }
    if (tabs.length > 0) {
      return tabs;
    }
    return [
      { key: 'recommend', title: '推荐', sort: 1 },
      { key: 'sale', title: '特卖', sort: 2 },
      { key: 'hot', title: '热销', sort: 3 },
      { key: 'tea', title: '茶叶', sort: 4 },
      { key: 'ware', title: '茶具', sort: 5 }
    ];
  }

  private featuredBannerCount(): number {
    return this.featuredBannerImages.length;
  }

  private featuredNormalizeBannerIndex(index: number): number {
    const count = this.featuredBannerCount();
    if (count <= 0) {
      return 0;
    }
    let next = index;
    while (next < 0) {
      next += count;
    }
    while (next >= count) {
      next -= count;
    }
    return next;
  }

  private featuredCurrentBannerImage(): string {
    const count = this.featuredBannerCount();
    if (count <= 0) {
      return '';
    }
    const index = this.featuredNormalizeBannerIndex(this.featuredBannerIndex);
    return this.featuredBannerImages[index];
  }

  private featuredTabTextOpacity(tabKey: string): number {
    return tabKey === this.featuredActiveTabKey ? 1 : 0.62;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(this.topSectionHeight())
        .backgroundColor(this.showBanner ? Colors.brandPrimary : Colors.pageBackground);

      Column()
        .width(540)
        .height(380)
        .borderRadius(270)
        .backgroundColor(Colors.brandHalo)
        .position({ x: -78, y: -128 });

      Column()
        .width(343)
        .height(343)
        .borderRadius(172)
        .backgroundColor(Colors.brandSecondary)
        .opacity(0.2)
        .position({ x: 156, y: -170 });


      Row() {
        Image($r('app.media.home_location_icon'))
          .height(15)
          .objectFit(ImageFit.Contain)
          .margin({ right: 4 });
        Text('梅州市.梅江区')
          .fontSize(10)
          .fontColor($r('sys.color.comp_background_list_card'));
        Blank();
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.home_notice_icon'))
            .width(16)
            .height(12)
            .objectFit(ImageFit.Contain);
          Stack({ alignContent: Alignment.Center }) {
            Image($r('app.media.home_notice_badge'))
              .width(12)
              .height(12)
              .objectFit(ImageFit.Contain);
            Text('23')
              .fontSize(7)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.cardBackground);
          }
          .position({ x: 11, y: 0 });
        }
        .width(18)
        .height(18)
        .onClick(() => NavService.go(AppRoute.CART));
      }
      .width('100%')
      .height(20)
      .position({ x: 0, y: 42 })
      .padding({ left: 24, right: 24 })
      .alignItems(VerticalAlign.Center);

      if (this.showBanner) {
        // Hidden tiny images force decode/cache early, reducing first-scroll stutter.
        Row() {
          ForEach(this.bannerImages, (imageUrl: string) => {
            Image(imageUrl)
              .width(1)
              .height(1)
              .objectFit(ImageFit.Cover)
              .opacity(0.001);
          }, (imageUrl: string) => imageUrl);
        }
        .position({ x: -1000, y: -1000 });
      } else {
        Row() {
          ForEach(this.featuredBannerImages, (imageUrl: string) => {
            Image(imageUrl)
              .width(1)
              .height(1)
              .objectFit(ImageFit.Cover)
              .opacity(0.001);
          }, (imageUrl: string) => imageUrl);
        }
        .position({ x: -1000, y: -1000 });
      }

      Row() {
        ForEach(this.topTabs, (tab: string, index: number) => {
          Column({ space: 4 }) {
            Text(index === 0 ? this.bannerModuleTitle : tab)
              .fontSize(20)
              .fontWeight(index === this.activeTopTab ? FontWeight.Medium : FontWeight.Regular)
              .fontColor(Colors.cardBackground)
              .opacity(index === this.activeTopTab ? 1 : 0.72)
              .onClick(() => {
                this.activeTopTab = index;
              });
            Row()
              .width(28)
              .height(3)
              .backgroundColor(Colors.cardBackground)
              .opacity(index === this.activeTopTab ? 1 : 0);
          }
          .margin({ right: 20 });
        }, (tab: string, index: number) => tab + index);
      }
      .position({ x: 142, y: 42 });

      Row() {
        Text('惠购嘉应茶叶，惊喜好茶')
          .fontSize(12)
          .fontColor(Colors.black)
          .opacity(0.33);
      }
      .width(316)
      .height(30)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Colors.cardBackground)
      .opacity(0.68)
      .borderRadius(15)
      .position({ x: 29, y: 84 });

      if (this.showBanner) {
        Stack({ alignContent: Alignment.Center }) {
          if (this.bannerCount() > 2) {
            Image(this.bannerAt(-2))
              .width(214)
              .height(106)
              .borderRadius(10)
              .objectFit(ImageFit.Cover)
              .opacity(0.42)
              .translate({ x: -66, y: 8 });
            Image(this.bannerAt(2))
              .width(214)
              .height(106)
              .borderRadius(10)
              .objectFit(ImageFit.Cover)
              .opacity(0.42)
              .translate({ x: 66, y: 8 });
          }

          if (this.bannerCount() > 1) {
            Image(this.bannerAt(-1))
              .width(232)
              .height(114)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .opacity(0.6)
              .translate({ x: -50, y: 5 });
            Image(this.bannerAt(1))
              .width(232)
              .height(114)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .opacity(0.6)
              .translate({ x: 50, y: 5 });
          }

          Image(this.bannerAt(0))
            .width(288)
            .height(141)
            .borderRadius(16)
            .objectFit(ImageFit.Cover)
            .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));
        }
        .translate({ x: this.bannerLayerOffsetX, y: 0 })
        .width(288)
        .height(141)
        .position({ x: 43, y: 122 });

        Stack({ alignContent: Alignment.Center }) {
          Swiper() {
            ForEach(this.bannerImages, (imageUrl: string) => {
              Row().width(288).height(141).id(imageUrl);
            }, (imageUrl: string) => imageUrl);
          }
          .width(288)
          .height(141)
          .indicator(false)
          .autoPlay(true)
          .interval(3200)
          .loop(true)
          .opacity(0.001)
          .onChange((index: number) => {
            const dir = this.slideDirection(index);
            const outOffset = 54 * dir;
            const inOffset = -54 * dir;
            animateTo({ duration: 95, curve: Curve.EaseIn }, () => {
              this.bannerLayerOffsetX = outOffset;
            });
            animateTo({ duration: 1, delay: 95, curve: Curve.Linear }, () => {
              this.activeBannerIndex = index;
              this.bannerLayerOffsetX = inOffset;
            });
            animateTo({ duration: 175, delay: 96, curve: Curve.EaseOut }, () => {
              this.bannerLayerOffsetX = 0;
            });
          });
        }
        .width(288)
        .height(141)
        .position({ x: 43, y: 122 });

        Row() {
          ForEach(this.bannerImages, (imageUrl: string, index: number) => {
            Row()
              .id(imageUrl)
              .width(this.activeBannerIndex === index ? 21 : 3)
              .height(3)
              .borderRadius(2)
              .backgroundColor(this.activeBannerIndex === index ? Colors.indicatorActive : Colors.indicatorInactive)
              .opacity(this.activeBannerIndex === index ? 1 : 0.3)
              .margin({ left: index === 0 ? 0 : 5 });
          }, (imageUrl: string) => imageUrl);
        }
        .position({ x: 168, y: 271 });
      } else {
        Row() {
          ForEach(this.featuredTabsDisplay(), (tab: FeaturedTab, index: number) => {
            Text(tab.title)
              .fontSize(this.featuredScale(14))
              .fontWeight(tab.key === this.featuredActiveTabKey ? FontWeight.Medium : FontWeight.Regular)
              .fontColor('#2F5452')
              .opacity(this.featuredTabTextOpacity(tab.key))
              .onClick(() => {
                void index;
                this.featuredActiveTabKey = tab.key;
              });
          }, (tab: FeaturedTab, index: number) => tab.key + index);
        }
        .width(this.featuredScale(314))
        .position({ x: this.featuredScale(31), y: this.featuredScale(126) })
        .justifyContent(FlexAlign.SpaceBetween);

        Stack({ alignContent: Alignment.Center }) {
          if (this.featuredCurrentBannerImage().length > 0) {
            Image(this.featuredCurrentBannerImage())
              .width(this.featuredMainWidth())
              .height(this.featuredBannerHeight())
              .borderRadius(this.featuredScale(10))
              .objectFit(ImageFit.Cover)
              .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));
          } else {
            Row()
              .width(this.featuredMainWidth())
              .height(this.featuredBannerHeight())
              .borderRadius(this.featuredScale(10))
              .backgroundColor(Colors.brandPrimary);
          }

          Swiper() {
            ForEach(this.featuredBannerImages, (imageUrl: string) => {
              Row()
                .id(imageUrl)
                .width(this.featuredMainWidth())
                .height(this.featuredBannerHeight());
            }, (imageUrl: string) => imageUrl);
          }
          .width(this.featuredMainWidth())
          .height(this.featuredBannerHeight())
          .indicator(false)
          .autoPlay(true)
          .interval(3200)
          .loop(true)
          .opacity(0.001)
          .onChange((index: number) => {
            this.featuredBannerIndex = index;
          });
        }
        .position({ x: this.featuredMainLeft(), y: this.featuredScale(157) });

        Row() {
          ForEach(this.featuredBannerImages, (imageUrl: string, index: number) => {
            Row()
              .id(imageUrl)
              .width(this.featuredBannerIndex === index ? this.featuredScale(21) : this.featuredScale(3))
              .height(this.featuredScale(3))
              .borderRadius(this.featuredScale(2))
              .backgroundColor(this.featuredBannerIndex === index ? '#2F5452' : '#A2B8B4')
              .opacity(this.featuredBannerIndex === index ? 1 : 0.4)
              .margin({ left: index === 0 ? 0 : this.featuredScale(5) });
          }, (imageUrl: string) => imageUrl);
        }
        .width(this.featuredScale(41))
        .justifyContent(FlexAlign.Center)
        .position({
          x: this.featuredMainLeft() + (this.featuredMainWidth() - this.featuredScale(41)) / 2,
          y: this.featuredScale(318)
        });
      }
    }
    .width('100%')
    .height(this.topSectionHeight());
  }
}

@Component
export struct HomeFeaturePage {
  @State private activeTopTab: number = 0;
  @State private activeCategory: number = 0;
  @State private activeNav: number = 0;
  @State private currentRoute: AppRoute = AppRoute.HOME;
  @State private safeBottomInset: number = 0;
  @State private homeContentWidth: number = 375;
  @State private healthResult: string = '-';
  @State private healthDbResult: string = '-';
  @State private homeResult: string = '-';
  @State private authResult: string = '-';
  @State private bannerModuleTitle: string = '推荐';
  @State private reviewSectionTitle: string = '茶评';
  @State private newTeaSectionTitle: string = '新茶上市';
  @State private newTeaNotice: string = '限量好茶免费品，品出慢时光';
  @State private featuredSectionTitle: string = '精选';
  @State private featuredTabs: FeaturedTab[] = [
    { key: 'recommend', title: '推荐', sort: 1 },
    { key: 'sale', title: '特卖', sort: 2 },
    { key: 'hot', title: '热销', sort: 3 },
    { key: 'tea', title: '茶叶', sort: 4 },
    { key: 'ware', title: '茶具', sort: 5 }
  ];
  @State private featuredActiveTabKey: string = 'hot';
  @State private featuredSections: FeaturedSection[] = [
    {
      key: 'hero_banner',
      title: '主视觉',
      subtitle: '',
      layout: 'banner',
      sort: 1,
      items: [
        {
          title: '精选主图',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_banner_1.png?width=900&quality=72',
          priceText: '',
          linkValue: 'featured_hero_1',
          sort: 1,
          cards: []
        }
      ]
    },
    {
      key: 'tea_circle',
      title: '高山绿茶',
      subtitle: '',
      layout: 'circle_icons',
      sort: 2,
      items: [
        {
          title: '高山绿茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_3.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_1',
          sort: 1,
          cards: []
        },
        {
          title: '银针绿茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_4.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_2',
          sort: 2,
          cards: []
        },
        {
          title: '碧螺春',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_1.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_3',
          sort: 3,
          cards: []
        },
        {
          title: '菊花茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_2.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_4',
          sort: 4,
          cards: []
        },
        {
          title: '红茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_5.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_5',
          sort: 5,
          cards: []
        },
        {
          title: '花茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_6.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_6',
          sort: 6,
          cards: []
        },
        {
          title: '白茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_7.png?width=240&quality=72',
          priceText: '',
          linkValue: 'featured_circle_7',
          sort: 7,
          cards: []
        }
      ]
    },
    {
      key: 'boutique_recommend',
      title: '精品推荐',
      subtitle: '',
      layout: 'small_card_scroll',
      sort: 3,
      items: [
        {
          title: '绿茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_1.png?width=560&quality=72',
          priceText: '￥128',
          linkValue: 'featured_boutique_1',
          sort: 1,
          cards: []
        },
        {
          title: '白茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_2.png?width=560&quality=72',
          priceText: '￥168',
          linkValue: 'featured_boutique_2',
          sort: 2,
          cards: []
        },
        {
          title: '菊花茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_2.png?width=240&quality=72',
          priceText: '￥99',
          linkValue: 'featured_boutique_3',
          sort: 3,
          cards: []
        },
        {
          title: '红茶',
          subtitle: '',
          imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_1.png?width=240&quality=72',
          priceText: '￥118',
          linkValue: 'featured_boutique_4',
          sort: 4,
          cards: []
        }
      ]
    },
    {
      key: 'recommend_list',
      title: '推荐',
      subtitle: '',
      layout: 'list_card',
      sort: 4,
      items: [
        {
          title: '推荐组 1',
          subtitle: '',
          imageUrl: '',
          priceText: '',
          linkValue: 'featured_list_1',
          sort: 1,
          cards: [
            {
              name: '嘉应普洱茶',
              subtitle: '客家普洱茶',
              marketingText: '新品上市',
              soldCountText: '114214人买过',
              badgePrimary: '新品上市',
              badgeSecondary: '月销冠军',
              priceText: '￥114.00/盒',
              imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_1.png?width=320&quality=72',
              linkValue: 'featured_list_1_a',
              sort: 1
            },
            {
              name: '嘉应菊花茶',
              subtitle: '嘉应丰顺茶饼',
              marketingText: '限时折扣',
              soldCountText: '114244人买过',
              badgePrimary: '新品上市',
              badgeSecondary: '限时折扣',
              priceText: '￥53.00/盒',
              imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_2.png?width=320&quality=72',
              linkValue: 'featured_list_1_b',
              sort: 2
            }
          ]
        }
      ]
    }
  ];
  @State private featuredBannerImages: string[] = [
    'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_banner_1.png?width=900&quality=72'
  ];
  @State private featuredBannerIndex: number = 0;
  @State private selectedReviewTea: string = '绿茶';
  @State private bannerImages: string[] = [
    'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_banner_1.png?width=900&quality=72'
  ];
  private navTabsController: TabsController = new TabsController();
  // Design bottom-bar white area has 22px inset on both sides at 854px export width.
  private readonly navInsetRatio: number = 22 / 854;
  private readonly navStretchScale: number = 1 / (1 - this.navInsetRatio * 2);
  // In the exported bg, the hump visual center is ~6.5px right of geometric center on 854px canvas.
  private readonly navCenterVisualOffset: number = 8;
  private readonly navIconScale: number = 0.5;
  private readonly navBarHeight: number = 98;
  private readonly navTabLift: number = 28;
  private readonly navIconLabelGap: number = 5;
  // Fallback bottom inset for devices/simulators where avoid-area API reports 0 in immersive mode.
  private readonly safeBottomFallback: number = 10;

  private readonly categoryTabs: string[] = ['袋茶', '包茶', '茶具', '茶制品'];
  private readonly reviewHeaderTopOffset: number = 8;
  private readonly reviewCardSize: number = 68;
  private readonly reviewCardGap: number = 12;
  private readonly reviewCardRadius: number = 6;
  private readonly reviewCardOverlayOpacity: number = 0.4;
  @State private reviewTopics: ReviewTopic[] = [
    { title: '红茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_1.png?width=240&quality=72' },
    { title: '菊花茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_2.png?width=240&quality=72' },
    { title: '绿茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_3.png?width=240&quality=72' },
    { title: '普洱茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_4.png?width=240&quality=72' },
    { title: '大红袍', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_5.png?width=240&quality=72' },
    { title: '花茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_6.png?width=240&quality=72' },
    { title: '白茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_7.png?width=240&quality=72' }
  ];
  @State private newTeaItems: NewTeaItem[] = [
    {
      title: '五种健康茶',
      subtitle: '炉火很旺，钟声很响，手中清茶正温',
      imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_1.png?width=560&quality=72',
      wantsText: '114人想试'
    },
    {
      title: '银针绿茶',
      subtitle: '炉火很旺，钟声很响，手中清茶正温',
      imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_2.png?width=560&quality=72',
      wantsText: '514人想试'
    },
    {
      title: '碧螺春',
      subtitle: '晨雾初起，芽叶鲜活，香气更清雅',
      imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_1.png?width=560&quality=72',
      wantsText: '208人想试'
    },
    {
      title: '花香乌龙',
      subtitle: '花香甘润，回味绵长，适合慢品',
      imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_new_tea_2.png?width=560&quality=72',
      wantsText: '163人想试'
    }
  ];
  private readonly newTeaHeaderTopOffset: number = 8;
  private readonly sectionSidePadding: number = 16;
  private readonly newTeaVisibleTailRatio: number = 0.25;
  private readonly newTeaCardGap: number = 12;
  private readonly newTeaCardRadius: number = 10;
  private readonly newTeaBadgeRadius: number = 2;
  private readonly newTeaTextPadding: number = 10;
  private readonly newTeaCardAspectRatio: number = 142 / 166;
  private readonly newTeaImageRatio: number = 92 / 142;
  private readonly promoGapHorizontal: number = 11;
  private readonly promoGapVertical: number = 14;
  private readonly promoLargeAspectRatio: number = 262 / 166;
  private readonly promoSmallAspectRatio: number = 124 / 166;
  private readonly promoCardRadius: number = 8;
  private readonly featuredCircleGap: number = 18;
  private readonly featuredCircleSize: number = 68;
  private readonly featuredBoutiqueGap: number = 8;
  private readonly featuredBoutiqueWidthRatio: number = 109 / 343;
  private readonly featuredRecommendCardGap: number = 10;
  private readonly featuredTopTabsRowWidth: number = 314;
  private readonly featuredTopTabsRowLeft: number = 31;
  private readonly featuredMainWidthBase: number = 340;
  private readonly featuredMainLeftBase: number = 17;

  private optimizeImageUrl(url: string, width: number): string {
    const objectPrefix = '/storage/v1/object/public/';
    const renderPrefix = '/storage/v1/render/image/public/';
    let nextUrl = url;
    if (nextUrl.indexOf(objectPrefix) >= 0) {
      nextUrl = nextUrl.replace(objectPrefix, renderPrefix);
    }
    if (nextUrl.indexOf('width=') >= 0) {
      return nextUrl;
    }
    const params = `width=${width}&quality=72`;
    return nextUrl.indexOf('?') >= 0 ? `${nextUrl}&${params}` : `${nextUrl}?${params}`;
  }

  private normalizeReviewImageUrl(url: string): string {
    if (url.indexOf('home_review_card_') >= 0) {
      return url.replace('home_review_card_', 'home_review_bg_');
    }
    return url;
  }

  private sectionInnerWidth(): number {
    const inner: number = this.homeContentWidth - this.sectionSidePadding * 2;
    return inner > 0 ? inner : 343;
  }

  private currentNewTeaCardWidth(): number {
    const innerWidth: number = this.sectionInnerWidth();
    return (innerWidth - this.newTeaCardGap * 2) / (2 + this.newTeaVisibleTailRatio);
  }

  private currentNewTeaCardHeight(): number {
    return this.currentNewTeaCardWidth() * this.newTeaCardAspectRatio;
  }

  private currentNewTeaImageHeight(): number {
    return this.currentNewTeaCardHeight() * this.newTeaImageRatio;
  }

  private promoColumnWidth(): number {
    return (this.sectionInnerWidth() - this.promoGapHorizontal) / 2;
  }

  private promoScaleRatio(): number {
    return this.promoColumnWidth() / 166;
  }

  private promoScaled(value: number): number {
    return value * this.promoScaleRatio();
  }

  private promoLargeCardHeight(): number {
    return this.promoColumnWidth() * this.promoLargeAspectRatio;
  }

  private promoSmallCardHeight(): number {
    return this.promoColumnWidth() * this.promoSmallAspectRatio;
  }


  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.currentRoute === AppRoute.REVIEW_LIST) {
        ReviewListPage({
          teaName: this.selectedReviewTea,
          currentRoute: $currentRoute
        })
          .width('100%')
          .height('100%');
      } else {
        Column() {
          HomeTopSection({
            bannerModuleTitle: this.bannerModuleTitle,
            bannerImages: this.bannerImages,
            showBanner: this.activeTopTab === 0,
            homeContentWidth: this.homeContentWidth,
            featuredTabs: this.featuredTopTabsDisplay(),
            featuredBannerImages: this.featuredBannerImages,
            activeTopTab: $activeTopTab,
            featuredActiveTabKey: $featuredActiveTabKey,
            featuredBannerIndex: $featuredBannerIndex
          });

          Scroll() {
            Column({ space: 14 }) {
              if (ApiConfig.enableBackendProbe) {
                this.BackendProbeArea();
              }
              if (this.activeTopTab === 0) {
                this.KingKongArea();
                this.ReviewArea();
                this.NewTeaArea();
                this.PromoArea();
              } else {
                this.FeaturedArea();
              }
              Row().height(100);
            }
            .width('100%')
            .padding({ top: this.activeTopTab === 0 ? 10 : 0, bottom: 8 });
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .onAreaChange((oldValue, newValue) => {
          void oldValue;
          const width = Number(newValue.width);
          if (width > 0) {
            this.homeContentWidth = width;
          }
        })
        .backgroundColor(Colors.pageBackground);

        this.BottomNav();
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor(Colors.pageBackground);
  }

  private formatHomeResult(data: HomeData): string {
    const moduleTexts: string[] = [];
    for (let i = 0; i < data.modules.length; i++) {
      moduleTexts.push(`${data.modules[i].key}:${data.modules[i].title}`);
    }
    return `unread=${data.unreadCount}; modules=[${moduleTexts.join(', ')}]`;
  }

  private async testHealth(): Promise<void> {
    try {
      const data = await HomeRepository.getHealth();
      this.healthResult = data.status.length > 0 ? data.status : 'ok';
    } catch (err) {
      this.healthResult = this.formatError(err);
    }
  }

  private async testHealthDb(): Promise<void> {
    try {
      const data = await HomeRepository.getHealthDb();
      this.healthDbResult = data.status.length > 0 ? data.status : 'ok';
    } catch (err) {
      this.healthDbResult = this.formatError(err);
    }
  }

  private async testHome(): Promise<void> {
    try {
      const data = await HomeRepository.getHome();
      this.applyHomeModules(data);
      this.homeResult = this.formatHomeResult(data);
    } catch (err) {
      this.homeResult = this.formatError(err);
    }
  }

  private applyHomeModules(data: HomeData): void {
    const remoteBanners: string[] = [];
    if (data.banners !== undefined && data.banners !== null) {
      for (let i = 0; i < data.banners.length; i++) {
        const banner: HomeBannerData = data.banners[i];
        if (banner.imageUrl.length > 0) {
          remoteBanners.push(this.optimizeImageUrl(banner.imageUrl, 900));
        }
      }
    }
    if (remoteBanners.length > 0) {
      this.bannerImages = remoteBanners;
    }

    for (let i = 0; i < data.modules.length; i++) {
      const module: HomeModuleData = data.modules[i];
      if (module.key === 'banner' && module.title.length > 0) {
        this.bannerModuleTitle = module.title;
      }
      if (module.key === 'review') {
        if (module.title.length > 0) {
          this.reviewSectionTitle = module.title;
        }
        this.applyReviewTopics(module.payload?.topics, module.payload?.updatedAt);
      }
      if (module.key === 'new_tea') {
        if (module.title.length > 0) {
          this.newTeaSectionTitle = module.title;
        }
        this.applyNewTeaItems(module.payload?.items, module.payload?.notice, module.payload?.updatedAt);
      }
      if (module.key === 'featured') {
        if (module.title.length > 0) {
          this.featuredSectionTitle = module.title;
        }
        this.applyFeaturedTabs(module.payload?.tabs, module.payload?.activeTab);
        this.applyFeaturedSections(module.payload?.sections, module.payload?.updatedAt);
      }
    }
  }

  private withCacheVersion(url: string, version: number): string {
    if (version <= 0) {
      return url;
    }
    const marker = 'v=';
    if (url.indexOf(marker) >= 0) {
      return url;
    }
    return url.indexOf('?') >= 0 ? `${url}&v=${version}` : `${url}?v=${version}`;
  }

  private applyReviewTopics(topics?: HomeReviewTopicData[], updatedAt?: number): void {
    if (topics === undefined || topics === null || topics.length === 0) {
      return;
    }
    const version: number = updatedAt !== undefined && updatedAt !== null ? updatedAt : 0;
    const nextTopics: ReviewTopic[] = [];
    for (let i = 0; i < topics.length; i++) {
      const topic = topics[i];
      if (topic.title.length === 0 || topic.imageUrl.length === 0) {
        continue;
      }
      const normalizedImageUrl = this.normalizeReviewImageUrl(topic.imageUrl);
      const versionedImageUrl = this.withCacheVersion(normalizedImageUrl, version);
      nextTopics.push({
        title: topic.title,
        imageUrl: this.optimizeImageUrl(versionedImageUrl, 240)
      });
    }
    if (nextTopics.length > 0) {
      this.reviewTopics = nextTopics;
    }
  }

  private applyNewTeaItems(items?: HomeNewTeaItemData[], notice?: string, updatedAt?: number): void {
    if (notice !== undefined && notice !== null && notice.length > 0) {
      this.newTeaNotice = notice;
    }
    if (items === undefined || items === null || items.length === 0) {
      return;
    }
    const version: number = updatedAt !== undefined && updatedAt !== null ? updatedAt : 0;
    const nextItems: NewTeaItem[] = [];
    const sortedItems: HomeNewTeaItemData[] = [];
    for (let i = 0; i < items.length; i++) {
      sortedItems.push(items[i]);
    }
    sortedItems.sort((a: HomeNewTeaItemData, b: HomeNewTeaItemData) => a.sort - b.sort);
    for (let i = 0; i < sortedItems.length; i++) {
      const item = sortedItems[i];
      if (item.title.length === 0 || item.imageUrl.length === 0) {
        continue;
      }
      const versionedImageUrl = this.withCacheVersion(item.imageUrl, version);
      nextItems.push({
        title: item.title,
        subtitle: item.subtitle.length > 0 ? item.subtitle : '炉火很旺，钟声很响，手中清茶正温',
        imageUrl: this.optimizeImageUrl(versionedImageUrl, 560),
        wantsText: item.wantsText.length > 0 ? item.wantsText : '100人想试'
      });
    }
    if (nextItems.length > 0) {
      this.newTeaItems = nextItems;
    }
  }

  private applyFeaturedTabs(tabs?: HomeFeaturedTabData[], activeTab?: string): void {
    if (tabs !== undefined && tabs !== null && tabs.length > 0) {
      const sortedTabs: HomeFeaturedTabData[] = [];
      for (let i = 0; i < tabs.length; i++) {
        sortedTabs.push(tabs[i]);
      }
      sortedTabs.sort((a: HomeFeaturedTabData, b: HomeFeaturedTabData) => a.sort - b.sort);
      const nextTabs: FeaturedTab[] = [];
      for (let i = 0; i < sortedTabs.length; i++) {
        const tab = sortedTabs[i];
        if (tab.key.length === 0 || tab.title.length === 0) {
          continue;
        }
        nextTabs.push({ key: tab.key, title: tab.title, sort: tab.sort });
      }
      if (nextTabs.length > 0) {
        this.featuredTabs = nextTabs;
      }
    }
    if (activeTab !== undefined && activeTab !== null && activeTab.length > 0) {
      this.featuredActiveTabKey = activeTab;
    }
  }

  private applyFeaturedSections(sections?: HomeFeaturedSectionData[], updatedAt?: number): void {
    if (sections === undefined || sections === null || sections.length === 0) {
      return;
    }
    const version: number = updatedAt !== undefined && updatedAt !== null ? updatedAt : 0;
    const sortedSections: HomeFeaturedSectionData[] = [];
    for (let i = 0; i < sections.length; i++) {
      sortedSections.push(sections[i]);
    }
    sortedSections.sort((a: HomeFeaturedSectionData, b: HomeFeaturedSectionData) => a.sort - b.sort);
    const nextSections: FeaturedSection[] = [];
    for (let i = 0; i < sortedSections.length; i++) {
      const source = sortedSections[i];
      const mappedItems: FeaturedItem[] = this.mapFeaturedItems(source.items, version);
      nextSections.push({
        key: source.key,
        title: source.title,
        subtitle: source.subtitle,
        layout: source.layout,
        sort: source.sort,
        items: mappedItems
      });

      if (source.key === 'hero_banner' && source.items !== undefined && source.items !== null) {
        const heroItems: HomeFeaturedItemData[] = [];
        for (let j = 0; j < source.items.length; j++) {
          heroItems.push(source.items[j]);
        }
        heroItems.sort((a: HomeFeaturedItemData, b: HomeFeaturedItemData) => a.sort - b.sort);
        const nextFeaturedBanners: string[] = [];
        for (let j = 0; j < heroItems.length; j++) {
          const hero = heroItems[j];
          if (hero.imageUrl.length === 0) {
            continue;
          }
          const versionedImageUrl = this.withCacheVersion(hero.imageUrl, version);
          nextFeaturedBanners.push(this.optimizeImageUrl(versionedImageUrl, 900));
        }
        if (nextFeaturedBanners.length > 0) {
          this.featuredBannerImages = nextFeaturedBanners;
          if (this.featuredBannerIndex >= nextFeaturedBanners.length) {
            this.featuredBannerIndex = 0;
          }
        }
      }
    }
    if (nextSections.length > 0) {
      this.featuredSections = nextSections;
    }
  }

  private mapFeaturedItems(items: HomeFeaturedItemData[], version: number): FeaturedItem[] {
    const mapped: FeaturedItem[] = [];
    if (items === undefined || items === null) {
      return mapped;
    }
    const sortedItems: HomeFeaturedItemData[] = [];
    for (let i = 0; i < items.length; i++) {
      sortedItems.push(items[i]);
    }
    sortedItems.sort((a: HomeFeaturedItemData, b: HomeFeaturedItemData) => a.sort - b.sort);
    for (let i = 0; i < sortedItems.length; i++) {
      const item = sortedItems[i];
      const itemUrl = item.imageUrl.length > 0 ?
        this.optimizeImageUrl(this.withCacheVersion(item.imageUrl, version), 560) : '';
      mapped.push({
        title: item.title,
        subtitle: item.subtitle,
        imageUrl: itemUrl,
        priceText: item.priceText,
        linkValue: item.linkValue,
        sort: item.sort,
        cards: this.mapFeaturedListCards(item.cards, version)
      });
    }
    return mapped;
  }

  private mapFeaturedListCards(cards?: HomeFeaturedListCardData[], version?: number): FeaturedListCard[] {
    const mapped: FeaturedListCard[] = [];
    if (cards === undefined || cards === null || cards.length === 0) {
      return mapped;
    }
    const imageVersion: number = version !== undefined && version !== null ? version : 0;
    const sortedCards: HomeFeaturedListCardData[] = [];
    for (let i = 0; i < cards.length; i++) {
      sortedCards.push(cards[i]);
    }
    sortedCards.sort((a: HomeFeaturedListCardData, b: HomeFeaturedListCardData) => a.sort - b.sort);
    for (let i = 0; i < sortedCards.length; i++) {
      const card = sortedCards[i];
      const unit: string = card.price?.unit !== undefined ? card.price.unit : '';
      const amount: string = card.price?.amount !== undefined ? card.price.amount : '';
      const symbol: string = card.price?.currencySymbol !== undefined ? card.price.currencySymbol : '￥';
      const priceText = amount.length > 0 ? `${symbol}${amount}${unit}` : '';
      mapped.push({
        name: card.name,
        subtitle: card.subtitle,
        marketingText: card.marketingText,
        soldCountText: card.soldCountText,
        badgePrimary: card.badgePrimary,
        badgeSecondary: card.badgeSecondary,
        priceText: priceText,
        imageUrl: card.imageUrl.length > 0 ?
          this.optimizeImageUrl(this.withCacheVersion(card.imageUrl, imageVersion), 320) : '',
        linkValue: card.linkValue,
        sort: card.sort
      });
    }
    return mapped;
  }

  private async ensureLoggedIn(): Promise<void> {
    if (UserStore.isLoggedIn()) {
      this.authResult = 'ready';
      return;
    }
    if (ApiConfig.debugUsername.length === 0 || ApiConfig.debugPassword.length === 0) {
      this.authResult = 'skip(debug account empty)';
      return;
    }
    const loginData = await AuthRepository.login(ApiConfig.debugUsername, ApiConfig.debugPassword);
    UserStore.setSession(loginData.accessToken, loginData.user.id);
    this.authResult = `ok(${loginData.user.username})`;
  }

  private async bootstrapBackend(): Promise<void> {
    try {
      await this.ensureLoggedIn();
      await this.testHome();
    } catch (err) {
      this.authResult = this.formatError(err);
    }
  }

  private formatError(err: Object): string {
    const value = err as Record<string, Object>;
    const msgObj = value['message'];
    if (msgObj !== undefined && msgObj !== null) {
      return `error: ${msgObj}`;
    }
    const codeObj = value['code'];
    if (codeObj !== undefined && codeObj !== null) {
      return `error code: ${codeObj}`;
    }
    return `error: ${JSON.stringify(err)}`;
  }

  @Builder
  private BackendProbeArea() {
    Column({ space: 8 }) {
      Text('后端联调测试')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.brandPrimary);
      Text(`${ApiConfig.baseUrl}${ApiConfig.apiPrefix}`)
        .fontSize(11)
        .fontColor(Colors.textSecondary);
      Text(UserStore.isLoggedIn() || ApiConfig.authToken.length > 0 ? 'Token: configured' : 'Token: empty (/home may return 401)')
        .fontSize(10)
        .fontColor(Colors.textTertiary);
      Text(`auth: ${this.authResult}`)
        .fontSize(10)
        .fontColor(Colors.textSecondary);

      Row({ space: 8 }) {
        Button('auto-login')
          .fontSize(11)
          .height(30)
          .backgroundColor(Colors.brandPrimary)
          .onClick(() => this.bootstrapBackend());
        Button('/health')
          .fontSize(11)
          .height(30)
          .backgroundColor(Colors.brandPrimary)
          .onClick(() => this.testHealth());
        Button('/health/db')
          .fontSize(11)
          .height(30)
          .backgroundColor(Colors.brandPrimary)
          .onClick(() => this.testHealthDb());
        Button('/home')
          .fontSize(11)
          .height(30)
          .backgroundColor(Colors.brandPrimary)
          .onClick(() => this.testHome());
      }

      Text(`health: ${this.healthResult}`)
        .fontSize(10)
        .fontColor(Colors.textSecondary);
      Text(`healthDb: ${this.healthDbResult}`)
        .fontSize(10)
        .fontColor(Colors.textSecondary);
      Text(`home: ${this.homeResult}`)
        .fontSize(10)
        .fontColor(Colors.textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width(345)
    .padding(10)
    .backgroundColor(Colors.cardBackground)
    .borderRadius(10)
    .margin({ left: 16, top: 2 });
  }

  aboutToAppear(): void {
    this.refreshSafeBottomInset();
    this.loadHomeModulesAsync();
  }

  private loadHomeModulesAsync(): void {
    this.testHome();
  }

  private readAvoidBottomPx(lastWindow: window.Window, avoidType: window.AvoidAreaType): number {
    try {
      return lastWindow.getWindowAvoidArea(avoidType).bottomRect.height;
    } catch {
      return 0;
    }
  }

  private refreshSafeBottomInset(): void {
    window.getLastWindow(getContext(this)).then((lastWindow: window.Window) => {
      const systemBottomPx = this.readAvoidBottomPx(lastWindow, window.AvoidAreaType.TYPE_SYSTEM);
      const gestureBottomPx = this.readAvoidBottomPx(lastWindow, window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
      const maxBottomPx = Math.max(systemBottomPx, gestureBottomPx);
      const bottomVp = px2vp(maxBottomPx);
      this.safeBottomInset = bottomVp > 0 ? bottomVp : this.safeBottomFallback;
    }).catch(() => {
      this.safeBottomInset = this.safeBottomFallback;
    });
  }

  @Builder
  private KingKongArea() {
    Row() {
      ForEach(this.categoryTabs, (item: string, index: number) => {
        this.KingKongItem(item, index);
      }, (item: string, index: number) => item + index);
    }
    .width('100%')
    .padding({ left: 25, right: 25 })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  private categoryIcon(index: number) {
    if (index === 0) {
      return $r('app.media.home_category_bag_icon');
    }
    if (index === 1) {
      return $r('app.media.home_category_pack_icon');
    }
    if (index === 2) {
      return $r('app.media.home_category_set_icon');
    }
    return $r('app.media.home_category_product_icon');
  }

  private categoryItemWidth(index: number): number {
    if (index === 0) {
      return 32;
    }
    if (index === 1) {
      return 39;
    }
    if (index === 2) {
      return 41;
    }
    return 48;
  }

  private categoryIconWidth(index: number): number {
    if (index === 0) {
      return 31;
    }
    if (index === 1) {
      return 35;
    }
    if (index === 2) {
      return 41;
    }
    return 36;
  }

  private categoryIconHeight(index: number): number {
    if (index === 0) {
      return 36;
    }
    if (index === 1) {
      return 44;
    }
    if (index === 2) {
      return 39;
    }
    return 42;
  }

  private categoryLabelGap(index: number): number {
    return index === 2 ? 10 : 8;
  }

  @Builder
  private KingKongItem(label: string, index: number) {
    Column({ space: this.categoryLabelGap(index) }) {
      Row() {
        Image(this.categoryIcon(index))
          .width(this.categoryIconWidth(index))
          .height(this.categoryIconHeight(index))
          .objectFit(ImageFit.Contain)
          .opacity(this.activeCategory === index ? 1 : 0.9);
      }
      .width(this.categoryItemWidth(index))
      .height(44)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Bottom);

      Text(label)
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .fontColor(this.activeCategory === index ? Colors.brandPrimary : '#4D716F');
    }
    .width(this.categoryItemWidth(index))
    .onClick(() => {
      this.activeCategory = index;
    });
  }

  @Builder
  private ReviewArea() {
    Column({ space: 10 }) {
      Row() {
        Row()
          .width(3)
          .height(18)
          .borderRadius(3)
          .backgroundColor(Colors.brandPrimary)
          .margin({ right: 4, top: this.reviewHeaderTopOffset + 2 });

        Text(this.reviewSectionTitle)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('SourceHanSerifCN')
          .fontColor(Colors.brandPrimary)
          .margin({ top: this.reviewHeaderTopOffset });

        Row() {
          Image($r('app.media.home_review_community_icon'))
            .width(14)
            .height(14)
            .objectFit(ImageFit.Contain);
          Text('参与社区评价，集结好茶')
            .fontSize(10)
            .fontColor(Colors.textTertiary)
            .margin({ left: 6, top: 1 });
        }
        .margin({ left: 10, top: this.reviewHeaderTopOffset + 3 });
      }
      .alignItems(VerticalAlign.Top)
      .width('100%');

      Scroll() {
        Row({ space: this.reviewCardGap }) {
          ForEach(this.reviewTopics, (topic: ReviewTopic, index: number) => {
            this.ReviewCard(topic, index);
          }, (topic: ReviewTopic, index: number) => topic.title + index);
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .padding({ left: 16 });
  }

  @Builder
  private ReviewCard(topic: ReviewTopic, index: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      if (topic.imageUrl.length > 0) {
        Image(topic.imageUrl)
          .width(this.reviewCardSize)
          .height(this.reviewCardSize)
          .borderRadius(this.reviewCardRadius)
          .objectFit(ImageFit.Cover);
      } else {
        Row()
          .width(this.reviewCardSize)
          .height(this.reviewCardSize)
          .borderRadius(this.reviewCardRadius)
          .backgroundColor(Colors.reviewCardA);
      }

      Row()
        .width(this.reviewCardSize)
        .height(this.reviewCardSize)
        .borderRadius(this.reviewCardRadius)
        .backgroundColor(Colors.black)
        .opacity(this.reviewCardOverlayOpacity);

      Row() {
        Text(topic.title)
          .fontSize(14)
          .fontColor(Colors.cardBackground)
          .fontWeight(FontWeight.Medium);
      }
      .width(this.reviewCardSize)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 10 });
    }
    .width(this.reviewCardSize)
    .height(this.reviewCardSize)
    .borderRadius(this.reviewCardRadius)
    .border({ width: 2, color: '#C5D8AF' })
    .onClick(() => {
      void index;
      this.selectedReviewTea = topic.title;
      this.currentRoute = AppRoute.REVIEW_LIST;
      NavService.go(AppRoute.REVIEW_LIST);
    });
  }

  @Builder
  private NewTeaArea() {
    Column({ space: 10 }) {
      Row() {
        Row()
          .width(3)
          .height(18)
          .borderRadius(3)
          .backgroundColor(Colors.brandPrimary)
          .margin({ right: 4, top: this.newTeaHeaderTopOffset + 2 });

        Text(this.newTeaSectionTitle)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('SourceHanSerifCN')
          .fontColor(Colors.brandPrimary)
          .margin({ top: this.newTeaHeaderTopOffset });

        Row() {
          Image($r('app.media.home_new_tea_notice_icon'))
            .width(14)
            .height(14)
            .objectFit(ImageFit.Contain);
          Text(this.newTeaNotice)
            .fontSize(10)
            .fontColor(Colors.textTertiary)
            .margin({ left: 4, top: 1 });
        }
        .margin({ left: 8, top: this.newTeaHeaderTopOffset + 7 });

        Blank();
        Row() {
          Text('更多')
            .fontSize(12)
            .fontColor(Colors.textTertiary);
          Image($r('app.media.home_new_tea_more_arrow'))
            .width(12)
            .height(12)
            .objectFit(ImageFit.Contain)
            .margin({ left: 2 });
        }
          .padding({ right: 2, top: this.newTeaHeaderTopOffset + 7 })
          .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));
      }
      .alignItems(VerticalAlign.Top)
      .width('100%');

      Scroll() {
        Row({ space: this.newTeaCardGap }) {
          ForEach(this.newTeaItems, (item: NewTeaItem, index: number) => {
            this.NewTeaCard(item, index);
          }, (item: NewTeaItem, index: number) => item.title + item.imageUrl + index);
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .padding({ left: this.sectionSidePadding, right: this.sectionSidePadding });
  }

  @Builder
  private NewTeaCard(item: NewTeaItem, index: number) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        if (item.imageUrl.length > 0) {
          Image(item.imageUrl)
            .width('100%')
            .height(this.currentNewTeaImageHeight())
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: this.newTeaCardRadius, topRight: this.newTeaCardRadius, bottomLeft: 0, bottomRight: 0 });
        } else {
          Row()
            .width('100%')
            .height(this.currentNewTeaImageHeight())
            .backgroundColor(Colors.newTeaCardBackground)
            .borderRadius({ topLeft: this.newTeaCardRadius, topRight: this.newTeaCardRadius, bottomLeft: 0, bottomRight: 0 });
        }

        Image($r('app.media.home_new_tea_card_pattern'))
          .width('100%')
          .layoutWeight(1)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: this.newTeaCardRadius, bottomRight: this.newTeaCardRadius });
      }
      .width('100%')
      .height('100%');

      Column({ space: 4 }) {
        Row() {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.cardBackground);
          Blank();
          Text(item.wantsText)
            .fontSize(8)
            .fontColor(Colors.cardBackground)
            .padding({ left: 4, right: 4, top: 2, bottom: 1 })
            .borderRadius(this.newTeaBadgeRadius)
            .backgroundColor(Colors.danger);
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);

        Text(item.subtitle)
          .fontSize(10)
          .fontColor(Colors.cardBackground)
          .opacity(0.74)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width('100%')
      .padding({ left: this.newTeaTextPadding, right: this.newTeaTextPadding, bottom: this.newTeaTextPadding })
      .translate({ x: 0, y: 5 });
    }
    .width(this.currentNewTeaCardWidth())
    .height(this.currentNewTeaCardHeight())
    .borderRadius(this.newTeaCardRadius)
    .onClick(() => {
      void index;
      NavService.go(AppRoute.PRODUCT_DETAIL);
    });
  }

  @Builder
  private PromoArea() {
    Row() {
      Row({ space: this.promoGapHorizontal }) {
        this.PromoFlashCard();
        Column({ space: this.promoGapVertical }) {
          this.PromoSmallCard(
            '品鉴专区',
            '花小钱买单泡，对胃口再下手',
            $r('app.media.home_promo_tasting_thumb_1_3x'),
            $r('app.media.home_promo_tasting_thumb_2_3x'),
            $r('app.media.home_promo_card_pattern_top_3x')
          );
          this.PromoSmallCard(
            '习茶套装',
            '花小钱买单泡，对胃口再下手',
            $r('app.media.home_promo_set_thumb_1_3x'),
            $r('app.media.home_promo_set_thumb_2_3x'),
            $r('app.media.home_promo_card_pattern_bottom_3x')
          );
        }
        .layoutWeight(1);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);
    }
    .width('100%')
    .padding({ left: this.sectionSidePadding, right: this.sectionSidePadding });
  }

  @Builder
  private PromoFlashCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height(this.promoLargeCardHeight())
        .borderRadius(this.promoCardRadius)
        .backgroundColor('#71AD91')
        .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));

      Column() {
        Image($r('app.media.home_promo_flash_main_3x'))
          .width(this.promoScaled(150))
          .height(this.promoScaled(138))
          .margin({ left: this.promoScaled(8), top: this.promoScaled(40) })
          .borderRadius(6)
          .objectFit(ImageFit.Cover);
      }
      .width('100%')
      .height(this.promoLargeCardHeight());

      Row({ space: 4 }) {
        Text('今日秒杀')
          .fontSize(this.promoScaled(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.cardBackground);

        Row() {
          Text('今日价')
            .fontSize(this.promoScaled(8))
            .fontColor('#D85E53')
            .margin({ left: this.promoScaled(4) });
          Text('￥200')
            .fontSize(this.promoScaled(10))
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.cardBackground)
            .margin({ left: this.promoScaled(4), right: this.promoScaled(4) });
        }
        .height(this.promoScaled(14))
        .borderRadius(2)
        .border({ width: 1, color: '#D85E53' })
        .backgroundColor(Colors.transparent);
      }
      .margin({ left: this.promoScaled(8), top: this.promoScaled(12) });

      Text('2023新品客家特供碧\n螺春')
        .fontSize(this.promoScaled(14))
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.cardBackground)
        .margin({ left: this.promoScaled(12), top: this.promoScaled(183) });

      Row() {
        Text('98%好评')
          .fontSize(this.promoScaled(8))
          .fontColor(Colors.cardBackground);
      }
      .height(this.promoScaled(11))
      .padding({ left: this.promoScaled(5), right: this.promoScaled(5) })
      .backgroundColor('#D85E53')
      .borderRadius(2)
      .margin({ left: this.promoScaled(47), top: this.promoScaled(202) });

      Row() {
        Image($r('app.media.home_promo_buy_icon_3x'))
          .width(this.promoScaled(16))
          .height(this.promoScaled(16))
          .objectFit(ImageFit.Contain)
          .margin({ right: this.promoScaled(2) });
        Text('立即购买')
          .fontSize(this.promoScaled(16))
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.cardBackground);
      }
      .width(this.promoScaled(127))
      .height(this.promoScaled(32))
      .borderRadius(8)
      .backgroundColor('#D85E53')
      .justifyContent(FlexAlign.Center)
      .margin({ left: this.promoScaled(21), top: this.promoScaled(229) });
    }
    .width('100%')
    .height(this.promoLargeCardHeight())
    .layoutWeight(1)
    .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));
  }

  @Builder
  private PromoSmallCard(title: string, subtitle: string, leftThumb: Resource, rightThumb: Resource, patternImage: Resource) {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height(this.promoSmallCardHeight())
        .borderRadius(6)
        .backgroundColor('#71AD91');

      Image(patternImage)
        .width('100%')
        .height(this.promoScaled(49))
        .objectFit(ImageFit.Fill)
        .margin({ left: 0, top: this.promoScaled(79) });

      Column() {
        Text(title)
          .fontSize(this.promoScaled(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.cardBackground)
          .margin({ left: this.promoScaled(11), top: this.promoScaled(13) });
        Text(subtitle)
          .fontSize(this.promoScaled(8))
          .fontColor(Colors.cardBackground)
          .opacity(0.8)
          .margin({ left: this.promoScaled(11), top: this.promoScaled(2) });
      }

      Row({ space: this.promoScaled(7) }) {
        Image(leftThumb)
          .width(this.promoScaled(62))
          .height(this.promoScaled(62))
          .borderRadius(6)
          .objectFit(ImageFit.Cover);
        Image(rightThumb)
          .width(this.promoScaled(62))
          .height(this.promoScaled(62))
          .borderRadius(6)
          .objectFit(ImageFit.Cover);
      }
      .margin({ left: this.promoScaled(13), top: this.promoScaled(52) });
    }
    .width('100%')
    .height(this.promoSmallCardHeight())
    .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));
  }

  private featuredScale(value: number): number {
    return value * this.homeContentWidth / 375;
  }

  private featuredMainLeft(): number {
    return this.featuredScale(this.featuredMainLeftBase);
  }

  private featuredMainWidth(): number {
    return this.featuredScale(this.featuredMainWidthBase);
  }

  private featuredTopTabsRowLeftPx(): number {
    return this.featuredScale(this.featuredTopTabsRowLeft);
  }

  private featuredTopTabsRowWidthPx(): number {
    return this.featuredScale(this.featuredTopTabsRowWidth);
  }

  private featuredBannerHeight(): number {
    return this.featuredMainWidth() * (149 / 340);
  }

  private featuredCircleItemSize(): number {
    return this.featuredScale(58);
  }

  private featuredCircleGapX(): number {
    return this.featuredScale(36);
  }

  private featuredCircleGapY(): number {
    return this.featuredScale(17);
  }

  private featuredBoutiqueCardWidth(): number {
    return this.featuredMainWidth() * (109 / 340);
  }

  private featuredBoutiqueCardHeight(): number {
    return this.featuredBoutiqueCardWidth() * (131 / 109);
  }

  private featuredRecommendGroupWidth(): number {
    return this.featuredScale(341);
  }

  private featuredRecommendGroupHeight(): number {
    return this.featuredScale(224);
  }

  private featuredRecommendCardRowHeight(): number {
    return this.featuredScale(104);
  }

  private featuredRecommendCardImageWidth(): number {
    return this.featuredScale(133);
  }

  private featuredRecommendCardImageHeight(): number {
    return this.featuredScale(104);
  }

  private featuredTabTextOpacity(tabKey: string): number {
    return tabKey === this.featuredActiveTabKey ? 1 : 0.7;
  }

  private featuredTopTabsDisplay(): FeaturedTab[] {
    const tabs: FeaturedTab[] = [];
    for (let i = 0; i < this.featuredTabs.length && i < 5; i++) {
      tabs.push(this.featuredTabs[i]);
    }
    if (tabs.length > 0) {
      return tabs;
    }
    return [
      { key: 'recommend', title: '推荐', sort: 1 },
      { key: 'sale', title: '特卖', sort: 2 },
      { key: 'hot', title: '热销', sort: 3 },
      { key: 'tea', title: '茶叶', sort: 4 },
      { key: 'ware', title: '茶具', sort: 5 }
    ];
  }

  private featuredGetSection(key: string): FeaturedSection | undefined {
    for (let i = 0; i < this.featuredSections.length; i++) {
      const section = this.featuredSections[i];
      if (section.key === key) {
        return section;
      }
    }
    return undefined;
  }

  private featuredCircleItems(): FeaturedItem[] {
    const section = this.featuredGetSection('tea_circle');
    return section !== undefined ? section.items : [];
  }

  private featuredCircleDisplayItems(): FeaturedItem[] {
    const source = this.featuredCircleItems();
    const items: FeaturedItem[] = [];
    if (source.length === 0) {
      return items;
    }
    for (let i = 0; i < 8; i++) {
      items.push(source[i % source.length]);
    }
    return items;
  }

  private featuredCircleFirstRowItems(): FeaturedItem[] {
    const display = this.featuredCircleDisplayItems();
    return display.slice(0, 4);
  }

  private featuredCircleSecondRowItems(): FeaturedItem[] {
    const display = this.featuredCircleDisplayItems();
    return display.slice(4, 8);
  }

  private featuredBoutiqueItems(): FeaturedItem[] {
    const section = this.featuredGetSection('boutique_recommend');
    return section !== undefined ? section.items : [];
  }

  private featuredRecommendPrimaryItem(): FeaturedItem | undefined {
    const section = this.featuredGetSection('recommend_list');
    if (section === undefined || section.items.length === 0) {
      return undefined;
    }
    return section.items[0];
  }

  private featuredRecommendPrimaryCards(): FeaturedListCard[] {
    const item = this.featuredRecommendPrimaryItem();
    if (item === undefined || item.cards.length === 0) {
      return [];
    }
    const cards: FeaturedListCard[] = [];
    for (let i = 0; i < item.cards.length && i < 2; i++) {
      cards.push(item.cards[i]);
    }
    return cards;
  }

  private featuredBannerCount(): number {
    return this.featuredBannerImages.length;
  }

  private featuredNormalizeBannerIndex(index: number): number {
    const count = this.featuredBannerCount();
    if (count <= 0) {
      return 0;
    }
    let next = index;
    while (next < 0) {
      next += count;
    }
    while (next >= count) {
      next -= count;
    }
    return next;
  }

  private featuredCurrentBannerImage(): string {
    const count = this.featuredBannerCount();
    if (count <= 0) {
      return '';
    }
    const index = this.featuredNormalizeBannerIndex(this.featuredBannerIndex);
    return this.featuredBannerImages[index];
  }

  @Builder
  private FeaturedArea() {
    Column() {
      this.FeaturedKingKongArea();
      this.FeaturedBoutiqueArea();
    }
    .width('100%');
  }

  @Builder
  private FeaturedTopTabsStrip() {
    Row() {
      Row() {
        ForEach(this.featuredTopTabsDisplay(), (tab: FeaturedTab, index: number) => {
          Text(tab.title)
            .fontSize(14)
            .fontColor(Colors.cardBackground)
            .opacity(this.featuredTabTextOpacity(tab.key))
            .onClick(() => {
              void index;
              this.featuredActiveTabKey = tab.key;
            });
        }, (tab: FeaturedTab, index: number) => tab.key + index);
      }
      .width(this.featuredTopTabsRowWidthPx())
      .justifyContent(FlexAlign.SpaceBetween);
      Blank();
    }
    .width('100%')
    .padding({ left: this.featuredTopTabsRowLeftPx(), right: this.featuredScale(20) });
  }

  @Builder
  private FeaturedBannerArea() {
    Column({ space: this.featuredScale(12) }) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.featuredCurrentBannerImage().length > 0) {
          Image(this.featuredCurrentBannerImage())
            .width(this.featuredMainWidth())
            .height(this.featuredBannerHeight())
            .borderRadius(10)
            .objectFit(ImageFit.Cover)
            .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));
        } else {
          Row()
            .width(this.featuredMainWidth())
            .height(this.featuredBannerHeight())
            .borderRadius(10)
            .backgroundColor(Colors.brandPrimary);
        }

        Swiper() {
          ForEach(this.featuredBannerImages, (imageUrl: string) => {
            Row().width(this.featuredMainWidth()).height(this.featuredBannerHeight()).id(imageUrl);
          }, (imageUrl: string) => imageUrl);
        }
        .width(this.featuredMainWidth())
        .height(this.featuredBannerHeight())
        .indicator(false)
        .autoPlay(true)
        .interval(3200)
        .loop(true)
        .opacity(0.001)
        .onChange((index: number) => {
          this.featuredBannerIndex = index;
        });
      }

      Row() {
        ForEach(this.featuredBannerImages, (imageUrl: string, index: number) => {
          Row()
            .id(imageUrl)
            .width(this.featuredBannerIndex === index ? this.featuredScale(21) : this.featuredScale(3))
            .height(this.featuredScale(3))
            .borderRadius(this.featuredScale(2))
            .backgroundColor(this.featuredBannerIndex === index ? Colors.cardBackground : Colors.indicatorInactive)
            .opacity(this.featuredBannerIndex === index ? 1 : 0.36)
            .margin({ left: index === 0 ? 0 : this.featuredScale(5) });
        }, (imageUrl: string) => imageUrl);
      }
      .width(this.featuredScale(41))
      .justifyContent(FlexAlign.Center);
    }
    .margin({ left: this.featuredMainLeft(), top: this.featuredScale(14) });
  }

  @Builder
  private FeaturedKingKongArea() {
    if (this.featuredCircleDisplayItems().length > 0) {
      Column({ space: this.featuredCircleGapY() }) {
        Row({ space: this.featuredCircleGapX() }) {
          ForEach(this.featuredCircleFirstRowItems(), (item: FeaturedItem, index: number) => {
            this.FeaturedKingKongItem(item, index);
          }, (item: FeaturedItem, index: number) => item.title + item.imageUrl + 'k1' + index);
        }
        .width(this.featuredMainWidth());

        Row({ space: this.featuredCircleGapX() }) {
          ForEach(this.featuredCircleSecondRowItems(), (item: FeaturedItem, index: number) => {
            this.FeaturedKingKongItem(item, index + 4);
          }, (item: FeaturedItem, index: number) => item.title + item.imageUrl + 'k2' + index);
        }
        .width(this.featuredMainWidth());
      }
      .margin({ left: this.featuredMainLeft(), top: this.featuredScale(8) });
    }
  }

  @Builder
  private FeaturedKingKongItem(item: FeaturedItem, index: number) {
    Column({ space: this.featuredScale(8) }) {
      if (item.imageUrl.length > 0) {
        Image(item.imageUrl)
          .width(this.featuredCircleItemSize())
          .height(this.featuredCircleItemSize())
          .borderRadius(this.featuredCircleItemSize() / 2)
          .objectFit(ImageFit.Cover);
      } else {
        Row()
          .width(this.featuredCircleItemSize())
          .height(this.featuredCircleItemSize())
          .borderRadius(this.featuredCircleItemSize() / 2)
          .backgroundColor(Colors.newTeaCardBackground);
      }
      Text(item.title)
        .fontSize(14)
        .fontColor(Colors.textSecondary)
        .maxLines(1);
    }
    .width(this.featuredCircleItemSize())
    .onClick(() => {
      void index;
      NavService.go(AppRoute.PRODUCT_DETAIL);
    });
  }

  @Builder
  private FeaturedBoutiqueArea() {
    if (this.featuredBoutiqueItems().length > 0) {
      Column() {
        Row() {
          Row()
            .width(this.featuredScale(3))
            .height(this.featuredScale(18))
            .borderRadius(this.featuredScale(3))
            .backgroundColor(Colors.brandPrimary)
            .margin({ right: this.featuredScale(4), top: this.featuredScale(6) });
          Text('精品推荐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontFamily('SourceHanSerifCN')
            .letterSpacing(2)
            .fontColor(Colors.brandPrimary);
          Blank();
        }
        .width('100%')
        .padding({ left: this.featuredScale(18), right: this.featuredScale(17) });

        Scroll() {
          Row({ space: this.featuredScale(8) }) {
            ForEach(this.featuredBoutiqueItems(), (item: FeaturedItem, index: number) => {
              this.FeaturedBoutiqueCard(item, index);
            }, (item: FeaturedItem, index: number) => item.title + item.imageUrl + index);
          }
          .padding({ left: this.featuredMainLeft() });
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({ top: this.featuredScale(8) });

        this.FeaturedRecommendPrimaryGroup();
      }
      .width('100%')
      .margin({ top: this.featuredScale(16) });
    }
  }

  @Builder
  private FeaturedBoutiqueCard(item: FeaturedItem, index: number) {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (item.imageUrl.length > 0) {
        Image(item.imageUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(this.featuredScale(8));
      } else {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(Colors.newTeaCardBackground)
          .borderRadius(this.featuredScale(8));
      }

      Row()
        .width('100%')
        .height(this.featuredScale(35))
        .borderRadius({
          topLeft: 0,
          topRight: 0,
          bottomLeft: this.featuredScale(8),
          bottomRight: this.featuredScale(8)
        })
        .backgroundColor('#2F5452CC');

      Text(item.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.cardBackground)
        .margin({ left: this.featuredScale(8), bottom: this.featuredScale(9) });
    }
    .width(this.featuredBoutiqueCardWidth())
    .height(this.featuredBoutiqueCardHeight())
    .borderRadius(this.featuredScale(8))
    .onClick(() => {
      void index;
      NavService.go(AppRoute.PRODUCT_DETAIL);
    });
  }

  @Builder
  private FeaturedRecommendPrimaryGroup() {
    if (this.featuredRecommendPrimaryCards().length > 0) {
      Column({ space: this.featuredScale(16) }) {
        ForEach(this.featuredRecommendPrimaryCards(), (card: FeaturedListCard, index: number) => {
          this.FeaturedRecommendCard(card, index);
        }, (card: FeaturedListCard, index: number) => card.name + card.linkValue + index);
      }
      .width(this.featuredRecommendGroupWidth())
      .height(this.featuredRecommendGroupHeight())
      .padding(this.featuredScale(8))
      .borderRadius(this.featuredScale(8))
      .backgroundColor('#EEF4ED')
      .margin({ left: this.featuredMainLeft(), top: this.featuredScale(25) });
    }
  }

  @Builder
  private FeaturedRecommendCard(card: FeaturedListCard, index: number) {
    Row() {
      if (card.imageUrl.length > 0) {
        Image(card.imageUrl)
          .width(this.featuredRecommendCardImageWidth())
          .height(this.featuredRecommendCardImageHeight())
          .borderRadius(this.featuredScale(6))
          .objectFit(ImageFit.Cover);
      } else {
        Row()
          .width(this.featuredRecommendCardImageWidth())
          .height(this.featuredRecommendCardImageHeight())
          .borderRadius(this.featuredScale(6))
          .backgroundColor(Colors.newTeaCardBackground);
      }

      Column({ space: this.featuredScale(4) }) {
        Text(`${card.name} ${card.subtitle}\n${card.marketingText}`)
          .fontSize(14)
          .fontColor('#314D4C')
          .lineHeight(this.featuredScale(17))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        if (card.soldCountText.length > 0) {
          Text(card.soldCountText)
            .fontSize(10)
            .fontColor('#6C8B88');
        }

        Row({ space: this.featuredScale(4) }) {
          if (card.badgePrimary.length > 0) {
            Row() {
              Text(card.badgePrimary)
                .fontSize(8)
                .fontColor(Colors.cardBackground);
            }
            .height(this.featuredScale(14))
            .padding({ left: this.featuredScale(5), right: this.featuredScale(5) })
            .borderRadius(this.featuredScale(2))
            .backgroundColor('#D85E53');
          }
          if (card.badgeSecondary.length > 0) {
            Row() {
              Text(card.badgeSecondary)
                .fontSize(8)
                .fontColor(Colors.cardBackground);
            }
            .height(this.featuredScale(14))
            .padding({ left: this.featuredScale(5), right: this.featuredScale(5) })
            .borderRadius(this.featuredScale(2))
            .backgroundColor('#D85E53');
          }

          Blank();
          if (card.priceText.length > 0) {
            Text(card.priceText)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D85E53');
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);
      }
      .height(this.featuredRecommendCardRowHeight())
      .padding({ left: this.featuredScale(8), right: this.featuredScale(4), top: this.featuredScale(3) })
      .layoutWeight(1);
    }
    .width(this.featuredRecommendGroupWidth() - this.featuredScale(16))
    .height(this.featuredRecommendCardRowHeight())
    .onClick(() => {
      void index;
      NavService.go(AppRoute.PRODUCT_DETAIL);
    });
  }

  @Builder
  private BottomNav() {
    Stack({ alignContent: Alignment.TopStart }) {
      // Composite background from exact design parts selected by user.
      Image($r('app.media.nav_bg_top'))
        .width('100%')
        .height(76)
        .objectFit(ImageFit.Cover)
        .scale({ x: this.navStretchScale, y: 1, centerX: '50%', centerY: '50%' });
      Image($r('app.media.nav_bg_bottom'))
        .width('100%')
        .height(25 + this.safeBottomInset)
        .objectFit(ImageFit.Cover)
        .position({ x: 0, y: 72 })
        .scale({ x: this.navStretchScale, y: 1, centerX: '50%', centerY: '50%' });

      Tabs({ barPosition: BarPosition.End, controller: this.navTabsController }) {
        TabContent() { Row() }.tabBar(this.NavTabIcon(0))
        TabContent() { Row() }.tabBar(this.NavTabIcon(1))
        TabContent() { Row() }.tabBar(this.NavTabSpacer())
        TabContent() { Row() }.tabBar(this.NavTabIcon(2))
        TabContent() { Row() }.tabBar(this.NavTabIcon(3))
      }
      .width('100%')
      .height(this.navBarHeight)
      .vertical(false)
      .barMode(BarMode.Fixed)
      .backgroundColor(Colors.transparent)
      .onChange((index: number) => {
        if (index === 0) {
          this.activeNav = 0;
        } else if (index === 1) {
          this.activeNav = 1;
        } else if (index === 3) {
          this.activeNav = 2;
        } else if (index === 4) {
          this.activeNav = 3;
        }
      });

      Row() {
        Row() {
          Image($r('app.media.nav_center_icon_selected'))
            .width(54)
            .height(54)
            .objectFit(ImageFit.Contain);
        }
        .width(72)
        .height(72)
        .margin({ top: 4, left: this.navCenterVisualOffset })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .height(this.navBarHeight)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top);

      // Immediate tap response layer: update active state at touch-down time.
      Row() {
        this.NavTapZone(0, 0);
        this.NavTapZone(1, 1);
        this.NavCenterTapZone();
        this.NavTapZone(2, 3);
        this.NavTapZone(3, 4);
      }
      .width('100%')
      .height(this.navBarHeight)
      .padding({ left: 12, right: 12 });
    }
    .width('100%')
    .height(this.navBarHeight + this.safeBottomInset);
  }

  @Builder
  private NavTapZone(index: number, tabIndex: number) {
    Row()
      .layoutWeight(1)
      .height('100%')
      .onClick(() => {
        this.activeNav = index;
        this.navTabsController.changeIndex(tabIndex);
        if (index === 1) {
          NavService.go(AppRoute.FILTER);
        } else if (index === 2) {
          NavService.go(AppRoute.CART);
        } else if (index === 3) {
          NavService.go(AppRoute.PROFILE);
        }
      });
  }

  @Builder
  private NavCenterTapZone() {
    Row()
      .layoutWeight(1)
      .height('100%')
      .onClick(() => {
        this.activeNav = 0;
        this.navTabsController.changeIndex(0);
      });
  }

  @Builder
  private NavTabSpacer() {
    Row().width(1).height(1);
  }

  @Builder
  private NavTabIcon(index: number) {
    if (index === 0) {
      Column({ space: this.navIconLabelGap }) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.nav_home_icon_only_inactive'))
            .width(46 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 0 : 1);
          Image($r('app.media.nav_home_icon_only_active'))
            .width(46 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 1 : 0);
        }
        Text('首页')
          .fontSize(12)
          .fontColor(this.activeNav === index ? Colors.brandAccent : Colors.navTextInactive);
      }
      .width(46 * this.navStretchScale * this.navIconScale)
      .height(54 * this.navStretchScale * this.navIconScale)
      .margin({ bottom: this.navTabLift });
    } else if (index === 1) {
      Column({ space: this.navIconLabelGap }) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.nav_filter_icon_only_inactive'))
            .width(46 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 0 : 1);
          Image($r('app.media.nav_filter_icon_only_active'))
            .width(46 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 1 : 0);
        }
        Text('筛选')
          .fontSize(12)
          .fontColor(this.activeNav === index ? Colors.brandAccent : Colors.navTextInactive);
      }
      .width(46 * this.navStretchScale * this.navIconScale)
      .height(54 * this.navStretchScale * this.navIconScale)
      .margin({ bottom: this.navTabLift });
    } else if (index === 2) {
      Column({ space: this.navIconLabelGap }) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.nav_third_icon_only_inactive'))
            .width(50 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 0 : 1);
          Image($r('app.media.nav_third_icon_only_active'))
            .width(50 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 1 : 0);
        }
        Text('特权')
          .fontSize(12)
          .fontColor(this.activeNav === index ? Colors.brandAccent : Colors.navTextInactive);
      }
      .width(50 * this.navStretchScale * this.navIconScale)
      .height(54 * this.navStretchScale * this.navIconScale)
      .margin({ bottom: this.navTabLift });
    } else {
      Column({ space: this.navIconLabelGap }) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.nav_fourth_icon_only_inactive'))
            .width(48 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 0 : 1);
          Image($r('app.media.nav_fourth_icon_only_active'))
            .width(48 * this.navStretchScale * this.navIconScale)
            .height(40 * this.navStretchScale * this.navIconScale)
            .objectFit(ImageFit.Contain)
            .opacity(this.activeNav === index ? 1 : 0);
        }
        Text('我的')
          .fontSize(12)
          .fontColor(this.activeNav === index ? Colors.brandAccent : Colors.navTextInactive);
      }
      .width(48 * this.navStretchScale * this.navIconScale)
      .height(54 * this.navStretchScale * this.navIconScale)
      .margin({ bottom: this.navTabLift });
    }
  }
}
