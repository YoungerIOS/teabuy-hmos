import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../theme/Tokens';

@Component
export struct BannerCarousel {
  @Prop bannerImages: string[] = [];
  
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
          .onClick(() => NavService.go(AppRoute.PRODUCT_DETAIL));

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
