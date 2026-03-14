import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { promptAction } from '@kit.ArkUI';
import { Colors } from '../theme/Tokens';
import { HomeBannerData, HomeRepository, NavigationResolveData } from '../../../features/home/data/HomeRepository';

@Component
export struct BannerCarousel {
  @Link currentRoute: AppRoute;
  @Prop bannerImages: string[] = [];
  @Prop bannerItems: HomeBannerData[] = [];
  @Prop bannerNavData: NavigationResolveData[] = [];
  
  // Customizable properties
  @Prop bannerWidth: number = 288;
  @Prop bannerHeight: number = 141;
  @Prop autoPlayInterval: number = 3200;
  
  @Prop carouselId: string = 'default';
  
  @State private activeBannerIndex: number = 0;
  @State private bannerLayerOffsetX: number = 0;

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

  private bannerItemAt(offset: number): HomeBannerData | null {
    if (this.bannerItems.length === 0) {
      return null;
    }
    const count = this.bannerItems.length;
    let index = this.activeBannerIndex + offset;
    while (index < 0) {
      index += count;
    }
    while (index >= count) {
      index -= count;
    }
    return this.bannerItems[index] || null;
  }

  private bannerNavAt(offset: number): NavigationResolveData | null {
    if (this.bannerNavData.length === 0) {
      return null;
    }
    const count = this.bannerNavData.length;
    let index = this.activeBannerIndex + offset;
    while (index < 0) {
      index += count;
    }
    while (index >= count) {
      index -= count;
    }
    return this.bannerNavData[index] || null;
  }

  private routeFromString(route: string): AppRoute {
    switch (route) {
      case 'product_list':
        return AppRoute.PRODUCT_LIST;
      case 'product_detail':
        return AppRoute.PRODUCT_DETAIL;
      case 'review_list':
        return AppRoute.REVIEW_LIST;
      case 'webview':
        return AppRoute.WEBVIEW;
      case 'order_list':
        return AppRoute.ORDER_LIST;
      default:
        return AppRoute.HOME;
    }
  }

  private async handleBannerClick(): Promise<void> {
    const cachedNav = this.bannerNavAt(0);
    if (cachedNav && cachedNav.route) {
      const targetRoute = this.routeFromString(cachedNav.route);
      if (targetRoute === AppRoute.WEBVIEW) {
        const url = cachedNav.params?.url || '';
        if (url.startsWith('http://') || url.startsWith('https://')) {
          this.currentRoute = targetRoute;
          NavService.go(targetRoute, cachedNav.params);
        } else {
          promptAction.showToast({ message: '链接配置错误,无法打开', duration: 2000 });
        }
      } else {
        this.currentRoute = targetRoute;
        NavService.go(targetRoute, cachedNav.params);
      }
      return;
    }
    const item = this.bannerItemAt(0);
    if (!item || !item.linkType) {
      this.currentRoute = AppRoute.PRODUCT_DETAIL;
      NavService.go(AppRoute.PRODUCT_DETAIL);
      return;
    }
    try {
      const navData = await HomeRepository.resolveNavigation(item.linkType, item.linkValue);
      const targetRoute = this.routeFromString(navData.route);
      if (targetRoute === AppRoute.WEBVIEW) {
        const url = navData.params?.url || '';
        if (url.startsWith('http://') || url.startsWith('https://')) {
          this.currentRoute = targetRoute;
          NavService.go(targetRoute, navData.params);
        } else {
          promptAction.showToast({ message: '链接配置错误,无法打开', duration: 2000 });
        }
      } else {
        this.currentRoute = targetRoute;
        NavService.go(targetRoute, navData.params);
      }
    } catch (error) {
      console.error('Failed to resolve banner navigation:', error);
      this.currentRoute = AppRoute.PRODUCT_LIST;
      NavService.go(AppRoute.PRODUCT_LIST);
    }
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

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // Base images logic for custom animation
        if (this.bannerCount() > 1) {
          Image(this.bannerAt(-1))
            .width(this.bannerWidth * 0.8)
            .height(this.bannerHeight * 0.8)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
            .opacity(0.6)
            .translate({ x: -50, y: 5 });

          Image(this.bannerAt(1))
            .width(this.bannerWidth * 0.8)
            .height(this.bannerHeight * 0.8)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
            .opacity(0.6)
            .translate({ x: 50, y: 5 });
        }

        Image(this.bannerAt(0))
          .width(this.bannerWidth)
          .height(this.bannerHeight)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            void this.handleBannerClick();
          });

      }
      .translate({ x: this.bannerLayerOffsetX, y: 0 })
      .width(this.bannerWidth)
      .height(this.bannerHeight);

      // Hidden Swiper driving the state
      Stack({ alignContent: Alignment.Center }) {
        Swiper() {
          ForEach(this.bannerImages, (imageUrl: string, index: number) => {
            Row().width(this.bannerWidth).height(this.bannerHeight).id(this.carouselId + '_' + imageUrl + index.toString());
          }, (imageUrl: string, index: number) => this.carouselId + '_' + imageUrl + index.toString());
        }
        .width(this.bannerWidth)
        .height(this.bannerHeight)
        .indicator(false)
        .autoPlay(true)
        .interval(this.autoPlayInterval)
        .loop(true)
        .onClick(() => {
          void this.handleBannerClick();
        })
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
      .width(this.bannerWidth)
      .height(this.bannerHeight)
      .position({ x: 0, y: 0 }); // overlay

      // Custom Indicators
      Row() {
        ForEach(this.bannerImages, (imageUrl: string, index: number) => {
          Row()
            .id(this.carouselId + '_indicator_' + imageUrl + index.toString())
            .width(this.activeBannerIndex === index ? 21 : 3)
            .height(3)
            .borderRadius(2)
            .backgroundColor(this.activeBannerIndex === index ? Colors.indicatorActive : Colors.indicatorInactive)
            .opacity(this.activeBannerIndex === index ? 1 : 0.3)
            .margin({ left: index === 0 ? 0 : 5 });
        }, (imageUrl: string, index: number) => this.carouselId + '_indicator_' + imageUrl + index.toString());
      }
      .margin({ top: 8 });
    }
  }
}
