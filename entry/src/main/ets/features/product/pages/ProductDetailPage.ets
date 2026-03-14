import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { RouteParams } from '../../../router/RouteParams';
import { CartItem } from '../../cart/data/CartRepository';
import { CartRemoteRepository } from '../../cart/data/CartRemoteRepository';
import { CartStorage } from '../../cart/data/CartStorage';
import { HomeRepository, ProductDetailData, ProductSkuItem, FeaturedListCard } from '../../home/data/HomeRepository';
import { promptAction } from '@kit.ArkUI';

interface ReviewItem {
  name: string;
  date: string;
  content: string;
  likes: number;
  avatar: Resource;
}

class PriceParts {
  symbol: string = '';
  amount: string = '';
  unit: string = '';
}

@Component
export struct ProductDetailPage {
  @Link currentRoute: AppRoute;
  @State private pageWidth: number = 375;
  @State private activeTab: number = 0; // 0: 商品 1: 详情 2: 评价
  @State private productId: string = '';
  @State private productDetail: ProductDetailData = new ProductDetailData();
  @State private fallbackName: string = '';
  @State private fallbackPriceText: string = '';
  @State private fallbackImageUrl: string = '';

  private s(value: number): number {
    return value * this.pageWidth / 375;
  }

  private reviews(): ReviewItem[] {
    return [
      {
        name: '德川',
        date: '2023-5-15',
        content: '从去年开始一直在这家买茶叶，很放心每次买的都很满意，店家也很用心。朋友来家里玩给她喝了这个茶叶都说好，满满的清香。',
        likes: 1145,
        avatar: $r('app.media.profile_interest_avatar_1_3x')
      } as ReviewItem,
      {
        name: '周振伦',
        date: '2023-5-15',
        content: '从去年开始一直在这家买茶叶，很放心每次买的都很满意，店家也很用心。朋友来家里玩给她喝了这个茶叶都说好，满满的清香。',
        likes: 1145,
        avatar: $r('app.media.profile_interest_avatar_2_3x')
      } as ReviewItem
    ];
  }

  aboutToAppear(): void {
    const params = NavService.getParams();
    if (params && params.productId) {
      this.productId = params.productId;
    }
    if (params && params.name) {
      this.fallbackName = params.name;
    }
    if (params && params.priceText) {
      this.fallbackPriceText = params.priceText;
    }
    if (params && params.imageUrl) {
      this.fallbackImageUrl = params.imageUrl;
    }

    if (this.productId.length > 0) {
      this.loadProductDetail();
    }
  }

  private async loadProductDetail(): Promise<void> {
    try {
      const detail = await HomeRepository.getProductDetail(this.productId);
      this.productDetail = detail;
    } catch (error) {
      console.error('Failed to load product detail:', error);
    }
  }

  private getPrimarySku(): ProductSkuItem | undefined {
    return this.productDetail.skus.length > 0 ? this.productDetail.skus[0] : undefined;
  }

  private displayPriceText(): string {
    const sku = this.getPrimarySku();
    if (sku && sku.priceText.length > 0) {
      return sku.priceText;
    }
    return this.fallbackPriceText;
  }

  private displayName(): string {
    return this.productDetail.name.length > 0 ? this.productDetail.name : this.fallbackName;
  }

  private displaySubtitle(): string {
    if (this.productDetail.subtitle.length > 0) {
      return this.productDetail.subtitle;
    }
    return this.productDetail.description;
  }

  private displayImageUrl(): string {
    if (this.productDetail.mainImageUrl.length > 0) {
      return this.productDetail.mainImageUrl;
    }
    if (this.productDetail.images.length > 0) {
      return this.productDetail.images[0];
    }
    return this.fallbackImageUrl;
  }

  private displaySoldCount(): number {
    return this.productDetail.soldCount > 0 ? this.productDetail.soldCount : 0;
  }

  private addToCart(): void {
    const card = this.buildCartCard();
    const existing: CartItem[] = AppStorage.get<CartItem[]>('cartItems') || [];
    const index = existing.findIndex((item: CartItem) => {
      if (card.id && card.id.length > 0 && item.product.id && item.product.id.length > 0) {
        return item.product.id === card.id;
      }
      return item.product.name ? item.product.name === card.name : false;
    });
    if (index >= 0) {
      const updated = existing[index];
      existing[index] = new CartItem(updated.id, updated.product, updated.quantity + 1, updated.selected);
    } else {
      const id = card.id && card.id.length > 0 ? card.id : Date.now().toString();
      existing.push(new CartItem(id, card, 1, false));
    }
    CartStorage.update([...existing]);

    const sku = this.getPrimarySku();
    if (sku) {
      void CartRemoteRepository.addItem(sku.id, 1).catch((error: Error) => {
        console.error('Failed to add cart item remotely:', error);
      });
    } else {
      promptAction.showToast({ message: '缺少SKU，无法加入购物车' });
    }
    promptAction.showToast({ message: '已加入购物车' });
  }

  private parsePriceText(priceText: string): PriceParts {
    const parts = new PriceParts();
    const match = priceText.match(/^([^0-9]*)([0-9.]+)(.*)$/);
    if (match) {
      parts.symbol = match[1] || '';
      parts.amount = match[2] || '';
      parts.unit = match[3] || '';
      return parts;
    }
    parts.amount = priceText;
    return parts;
  }

  private buildCartCard(): FeaturedListCard {
    const card = new FeaturedListCard();
    const sku = this.getPrimarySku();
    card.id = this.productDetail.id.length > 0 ? this.productDetail.id : this.productId;
    if (sku) {
      card.skuId = sku.id;
    }
    card.name = this.displayName();
    card.subtitle = this.displaySubtitle();
    card.imageUrl = this.displayImageUrl();
    card.priceText = this.displayPriceText();
    card.soldCountText = this.displaySoldCount() > 0 ? `${this.displaySoldCount()}人买过` : '';
    card.badgePrimary = this.productDetail.badgePrimary;
    card.badgeSecondary = this.productDetail.badgeSecondary;
    return card;
  }

  private displayPriceSymbol(): string {
    return this.parsePriceText(this.displayPriceText()).symbol;
  }

  private displayPriceAmount(): string {
    return this.parsePriceText(this.displayPriceText()).amount;
  }

  private displayPriceUnit(): string {
    return this.parsePriceText(this.displayPriceText()).unit;
  }

  @Builder
  private GuaranteeItem(label: string) {
    Row() {
      Image($r('app.media.product_icon_right_3x'))
        .width(this.s(10))
        .height(this.s(10))
        .objectFit(ImageFit.Contain);

      Text(label)
        .fontSize(this.s(10))
        .fontColor('#999999')
        .margin({ left: this.s(2) });
    }
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private HeaderBar() {
    Column() {
      Row() {
        Image($r('app.media.product_icon_back_3x'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            // 返回上一页
            NavService.back();
            this.currentRoute = NavService.getCurrentRoute();
          });

        Row({ space: this.s(56) }) {
          this.HeaderTab('商品', 0);
          this.HeaderTab('详情', 1);
          this.HeaderTab('评价', 2);
        }

        Image($r('app.media.product_icon_share_3x'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain);
      }
      .width('100%')
      .height(30)
      .padding({ left: 18, right: 11 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .height(81)
    .padding({ top: 41 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#97C9C0', 0], ['#71AD91', 1]]
    });
  }

  @Builder
  private HeaderTab(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(this.s(16))
        .fontWeight(index === this.activeTab ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(Color.White)
        .opacity(index === this.activeTab ? 1 : 0.8);

      Row()
        .width(this.s(30))
        .height(this.s(3))
        .backgroundColor(index === this.activeTab ? '#4D716F' : Color.Transparent)
        .borderRadius(this.s(10))
        .margin({ top: this.s(4) });
    }
    .onClick(() => {
      this.activeTab = index;
    });
  }

  @Builder
  private ProductCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Row()
          .width('100%')
          .height(this.s(183));

        Column() {
          Row() {
            Row() {
              Text(this.displayPriceSymbol())
                .fontSize(this.s(16))
                .fontColor('#D85E53')
                .fontWeight(FontWeight.Bold)
                .margin({ top: this.s(11) });

              Text(this.displayPriceAmount())
                .fontSize(this.s(39))
                .fontColor('#D85E53')
                .fontWeight(FontWeight.Bold)
                .margin({ left: this.s(1) });

              if (this.displayPriceUnit().length > 0) {
                Text(this.displayPriceUnit())
                  .fontSize(this.s(16))
                  .fontColor('#D85E53')
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: this.s(11), left: this.s(1) });
              }
            }
            .alignItems(VerticalAlign.Bottom);

            Blank();

            Text(this.displaySoldCount() > 0 ? `月销${this.displaySoldCount()}+` : '')
              .fontSize(this.s(14))
              .fontColor('#B9B9B9')
              .margin({ bottom: this.s(6) });
          }
          .width('100%')
          .alignItems(VerticalAlign.Bottom);

          Text(this.displayName().length > 0 ? `${this.displayName()}${this.displaySubtitle().length > 0 ? '\n' + this.displaySubtitle() : ''}` : '')
            .fontSize(this.s(34 / 3))
            .fontColor('#4D716F')
            .lineHeight(this.s(20))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .margin({ top: this.s(3) });

          Row() {
            Row() {
              Image($r('app.media.product_icon_like_3x'))
                .width(this.s(14))
                .height(this.s(14))
                .objectFit(ImageFit.Contain)
                .margin({ right: this.s(3) });
              Text('1145')
                .fontSize(this.s(10))
                .fontColor('#9E9E9E');
            }
            .alignItems(VerticalAlign.Center);

            Blank();

            Row() {
              Image($r('app.media.product_icon_gift_3x'))
                .width(this.s(14))
                .height(this.s(14))
                .objectFit(ImageFit.Contain)
                .margin({ right: this.s(3) });
              Text('送给TA')
                .fontSize(this.s(10))
                .fontColor('#9E9E9E');
            }
            .alignItems(VerticalAlign.Center);

            Blank();

            Text(this.displaySoldCount() > 0 ? `已售${this.displaySoldCount()}` : '')
              .fontSize(this.s(10))
              .fontColor('#9E9E9E');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 15, right: 15 })
          .margin({ top: this.s(7) });
        }
        .width('100%')
        .padding({ left: this.s(12), right: this.s(12), top: this.s(7), bottom: this.s(10) })
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: this.s(10), bottomRight: this.s(10) })
        .alignItems(HorizontalAlign.Start);
      }
      .width(this.s(341))
      .height(this.s(297))
      .backgroundColor(Color.White)
      .borderRadius(this.s(10))
      .shadow({ radius: 8, color: 'rgba(77,113,111,0.2)', offsetX: 0, offsetY: 4 });

      Stack({ alignContent: Alignment.TopEnd }) {
        if (this.displayImageUrl().length > 0) {
          Image(this.displayImageUrl())
            .width('100%')
            .height(this.s(183))
            .objectFit(ImageFit.Cover)
            .borderRadius(this.s(10));
        } else {
          Row()
            .width('100%')
            .height(this.s(183))
            .borderRadius(this.s(10))
            .backgroundColor('#DDE7E2');
        }

        Image($r('app.media.product_badge_sales_component_3x'))
          .width(this.s(33))
          .height(this.s(54))
          .objectFit(ImageFit.Fill);
      }
      .width(this.s(341))
      .height(this.s(183))
      .position({ x: 0, y: 0 });
    }
    .width(this.s(341))
    .height(this.s(297));
  }

  @Builder
  private CouponCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.s(339))
        .height(this.s(94))
        .backgroundColor(Color.White)
        .borderRadius(this.s(8))
        .shadow({ radius: 8, color: 'rgba(77,113,111,0.2)', offsetX: 0, offsetY: 4 });

      Image($r('app.media.product_coupon_watermark_3x'))
        .width(this.s(97))
        .height(this.s(81))
        .objectFit(ImageFit.Contain)
        .position({ x: this.s(252), y: this.s(10) })
        .opacity(0.15);

      Column() {
        Row() {
          Text('领取优惠券')
            .fontSize(this.s(16))
            .fontColor('#D85E53');

          Blank();

          Text('›')
            .fontSize(this.s(24))
            .fontColor('#9E9E9E');
        }
        .width('100%');

        Row() {
          this.DashedSeparator();
        }

        Row({ space: this.s(8) }) {
          Text('平台保障')
            .fontSize(this.s(10))
            .fontColor('#666666');
          this.GuaranteeItem('正品保证');
          this.GuaranteeItem('快速发货');
          this.GuaranteeItem('专业包装');
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ top: this.s(7) });

        Row() {
          Row() {
            Text('满减')
              .fontSize(this.s(12))
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White);
          }
          .height(this.s(18))
          .padding({ left: this.s(10), right: this.s(10) })
          .backgroundColor('#FFCD45')
          .borderRadius(this.s(2))
          .justifyContent(FlexAlign.Center);

          Text('本品参加满99减90元活动')
            .fontSize(this.s(10))
            .fontColor('#999999')
            .margin({ left: this.s(8), top: this.s(3) });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ top: this.s(9) });
      }
      .width(this.s(315))
      .padding({ left: this.s(14), top: this.s(9) })
      .alignItems(HorizontalAlign.Start);
    }
    .width(this.s(339))
    .height(this.s(94));
  }

  @Builder
  private ReviewCard() {
    Column() {
      Row() {
        Text(`商品评价（${this.activeTab === 2 ? '11451' : '1145'}）`)
          .fontSize(this.s(14))
          .fontColor('#333333');

        Blank();

        Image($r('app.media.product_icon_filter_3x'))
          .width(this.s(22))
          .height(this.s(22))
          .objectFit(ImageFit.Contain);

        Text('筛选')
          .fontSize(this.s(12))
          .fontColor('#666666')
          .margin({ left: this.s(2) });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      Row() {
        this.DashedSeparator()
      }
      .margin({ top: this.s(10), bottom: this.s(10)})

      if (this.activeTab === 2) {
        this.ReviewFilterArea();
      }

      ForEach(this.reviews(), (item: ReviewItem, index: number) => {
        this.ReviewItem(item, index !== this.reviews().length - 1);
      }, (item: ReviewItem, index: number) => `${item.name}_${index}`);
    }
    .width(this.s(339))
    .padding({ left: this.s(13), right: this.s(13), top: this.s(13), bottom: this.s(10) })
    .backgroundColor(Color.White)
    .borderRadius(this.s(10));
  }

  @Builder
  private ReviewFilterArea() {
    Column() {
      Text('○只看当前商品')
        .fontSize(this.s(10))
        .fontColor('#666666')
        .width('100%');

      Row({ space: this.s(7) }) {
        this.FilterChip('全部', true);
        this.FilterChip('图/视频100+', false);
        this.FilterChip('追评99+', false);
        this.FilterChip('好评99+', false);
      }
      .margin({ top: this.s(9) });

      Row({ space: this.s(7) }) {
        this.FilterChip('色泽纯正1145', false);
        this.FilterChip('颜色透亮156', false);
        this.FilterChip('口感不错496', false);
      }
      .margin({ top: this.s(8) });

      Row({ space: this.s(7) }) {
        this.FilterChip('性价比高1789', false);
        this.FilterChip('价格优惠1478', false);
        this.FilterChip('包装精美37', false);
      }
      .margin({ top: this.s(8), bottom: this.s(10) });
    }
    .width('100%');
  }

  @Builder
  private FilterChip(label: string, active: boolean) {
    Row() {
      Text(label)
        .fontSize(this.s(10))
        .fontColor(active ? '#D85E53' : '#707070');
    }
    .padding({ left: this.s(8), right: this.s(8), top: this.s(4), bottom: this.s(4) })
    .backgroundColor(active ? '#FFF5F4' : '#F4F4F4')
    .borderRadius(this.s(3))
    .border({ width: 1, color: active ? '#D85E53' : '#D4D4D4' });
  }

  @Builder
  private ReviewItem(item: ReviewItem, showDivider: boolean) {
    Column() {
      Row({ space: this.s(8) }) {
        Image(item.avatar)
          .width(this.s(32))
          .height(this.s(32))
          .borderRadius(this.s(16))
          .objectFit(ImageFit.Cover);

        Column() {
          Row() {
            Text(item.name)
              .fontSize(this.s(15))
              .fontColor('#4D4D4D')
              .fontWeight(FontWeight.Medium);

            Blank();

            Text('♥♥♥♥')
              .fontSize(this.s(13))
              .fontColor('#D85E53');
          }
          .width('100%');

          Text(item.date)
            .fontSize(this.s(10))
            .fontColor('#A0A0A0')
            .margin({ top: this.s(2) });

          Text(item.content)
            .fontSize(this.s(12))
            .fontColor('#4D4D4D')
            .lineHeight(this.s(17))
            .margin({ top: this.s(5) });

          Row() {
            Blank();
            Text(`${item.likes}`)
              .fontSize(this.s(10))
              .fontColor('#B9B9B9');
          }
          .width('100%')
          .margin({ top: this.s(4) });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      if (showDivider) {
        Row() {
          this.DashedSeparator()
        }
        .margin({ top: this.s(10), bottom: this.s(10)})
      }
    }
  }

  @Builder
  private DetailSection() {
    Column() {
      Text('商品详情')
        .fontSize(this.s(16))
        .fontColor('#4D716F')
        .fontWeight(FontWeight.Medium)
        .width('100%');

      Image('https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_4.png?v=4')
        .width('100%')
        .height(this.s(220))
        .objectFit(ImageFit.Cover)
        .borderRadius(this.s(10))
        .margin({ top: this.s(10) });

      Text('入口清甜，回甘明显，适合日常冲泡。')
        .fontSize(this.s(12))
        .fontColor('#666666')
        .width('100%')
        .margin({ top: this.s(8) });
    }
    .width(this.s(339))
    .padding({ left: this.s(12), right: this.s(12), top: this.s(12), bottom: this.s(12) })
    .backgroundColor(Color.White)
    .borderRadius(this.s(10));
  }

  @Builder
  private BottomActionBar() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height(this.s(58))
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: -2 });

      Row() {
        Column() {
          Image($r('app.media.product_icon_service_3x'))
            .width(this.s(24))
            .height(this.s(23.5))
            .objectFit(ImageFit.Contain);
          Text('客服')
            .fontSize(this.s(12))
            .fontColor('#4D716F')
            .margin({ top: this.s(2) });
        }
        .width(this.s(58))
        .alignItems(HorizontalAlign.Center);

        Column() {
          Image($r('app.media.product_icon_favorite_3x'))
            .width(this.s(24))
            .height(this.s(23.2))
            .objectFit(ImageFit.Contain);
          Text('收藏')
            .fontSize(this.s(12))
            .fontColor('#4D716F')
            .margin({ top: this.s(2) });
        }
        .width(this.s(58))
        .alignItems(HorizontalAlign.Center);

        Stack() {
          Image($r('app.media.product_bottom_actions_bg_3x'))
            .width(this.s(239))
            .height(this.s(61))
            .objectFit(ImageFit.Fill);

          Row() {
            Row() {
              Text('加入购物车')
                .fontSize(this.s(16))
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium);
            }
            .width(this.s(116))
            .height(this.s(58))
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.addToCart();
            });

            Row() {
              Text('立即购买')
                .fontSize(this.s(20))
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium);
            }
            .width(this.s(123))
            .height(this.s(58))
            .justifyContent(FlexAlign.Center)
            .onClick(async () => {
              const card = this.buildCartCard();
              const existing: CartItem[] = AppStorage.get<CartItem[]>('cartItems') || [];
              for (let i = 0; i < existing.length; i++) {
                existing[i].selected = false;
              }
              const index = existing.findIndex((item: CartItem) => {
                if (card.id && card.id.length > 0 && item.product.id && item.product.id.length > 0) {
                  return item.product.id === card.id;
                }
                return item.product.name ? item.product.name === card.name : false;
              });
              if (index >= 0) {
                existing[index].quantity = 1;
                existing[index].selected = true;
                existing[index].product = card;
              } else {
                const id = card.id && card.id.length > 0 ? card.id : Date.now().toString();
                existing.push(new CartItem(id, card, 1, true));
              }
              CartStorage.update([...existing]);
              const routeParams = new RouteParams();
              if (this.productId.length > 0) {
                routeParams.productId = this.productId;
              }
              const sku = this.getPrimarySku();
              if (sku) {
                routeParams.skuId = sku.id;
              }
              this.currentRoute = AppRoute.CHECKOUT;
              NavService.go(AppRoute.CHECKOUT, routeParams);
              if (sku) {
                void CartRemoteRepository.addItem(sku.id, 1).catch((error: Error) => {
                  console.error('Failed to add cart item remotely:', error);
                });
              }
            });
          }
          .width(this.s(239))
          .height(this.s(58));
        }
        .width(this.s(239))
        .height(this.s(61));
      }
      .width('100%')
      .height(this.s(58))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: this.s(10), right: this.s(0) });
    }
    .width('100%')
    .height(this.s(58));
  }

  @Builder
  private DashedSeparator() {
    Row()
      .width('100%')
      .height(0.1)
      .border({
        width: 1,
        color: '#4D716F',
        style: BorderStyle.Dashed
      })
      .opacity(0.2);
  }

  build() {
    Column() {
      this.HeaderBar();

      Scroll() {
        Column({ space: this.s(16) }) {
          this.ProductCard();
          this.CouponCard();
          if (this.activeTab === 1) {
            this.DetailSection();
          } else {
            this.ReviewCard();
          }
          Row().height(this.s(12));
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: this.s(17) });
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#F2F7F0');

      this.BottomActionBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F7F0')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onAreaChange((oldValue, newValue) => {
      void oldValue;
      const width = Number(newValue.width);
      if (width > 0) {
        this.pageWidth = width;
      }
    });
  }
}
