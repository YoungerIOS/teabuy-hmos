/**
 * 产品列表页面 (筛选界面2)
 * 产品筛选和列表展示页面
 */

import { router } from '@kit.ArkUI';
import { Colors } from '../../../core/ui/theme/Tokens';
import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { FeaturedListCard, HomeRepository, ProductListData, ProductQueryParams, ProductItem, ProductItemHelper } from '../../home/data/HomeRepository';
import { ProductCard } from '../../../shared/components/ProductCard';


@Component
export struct ProductListPage {
  @Link currentRoute: AppRoute;
  @State currentFilter: string = 'default'; // default, sales, price_asc, price_desc, new
  @State searchText: string = '';
  @State private pageWidth: number = 375;
  @State private products: FeaturedListCard[] = [];
  @State private isLoading: boolean = false;
  @State private keyword: string = '';
  @State private categoryKey: string = '';
  @State private activityKey: string = '';
  @State private topicKey: string = '';

  aboutToAppear(): void {
    // 从 NavService 获取参数
    const params = NavService.getParams();
    console.log('ProductListPage params:', JSON.stringify(params));
    
    if (params) {
      if (params.keyword) {
        this.keyword = params.keyword;
        this.searchText = params.keyword;
      }
      if (params.categoryKey) {
        this.categoryKey = params.categoryKey;
      }
      if (params.activityKey) {
        this.activityKey = params.activityKey;
      }
      if (params.topicKey) {
        this.topicKey = params.topicKey;
      }
    }
    
    // 加载商品数据
    this.loadProducts();
  }

  private async loadProducts(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    
    this.isLoading = true;
    console.log('Loading products with params:', {
      keyword: this.keyword,
      categoryKey: this.categoryKey,
      activityKey: this.activityKey,
      topicKey: this.topicKey
    });
    
    try {
      const params: ProductQueryParams = {
        keyword: this.keyword,
        categoryKey: this.categoryKey,
        activityKey: this.activityKey,
        topicKey: this.topicKey,
        page: 1,
        pageSize: 20
      };
      console.log('Calling HomeRepository.getProducts with params:', JSON.stringify(params));
      const data = await HomeRepository.getProducts(params);
      console.log('API response:', JSON.stringify(data));
      
      // 转换 ProductItem 到 FeaturedListCard
      this.products = data.items.map((item: ProductItem) => ProductItemHelper.toFeaturedListCard(item));
      console.log('Loaded products:', this.products.length);
    } catch (error) {
      console.error('Failed to load products:', error);
      // 失败时使用模拟数据
      this.products = this.getMockProducts();
      console.log('Using mock products due to error');
    } finally {
      this.isLoading = false;
    }
  }

  private getMockProducts(): FeaturedListCard[] {
    return [
      {
        name: '嘉应茗茶 铁观音清香型阿迪发',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_1.png',
        priceText: '￥128/盒',
        soldCountText: '月销2341',
        badgePrimary: '热销冠军'
      } as FeaturedListCard,
      {
        name: '嘉应茗茶 大红袍',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_2.png',
        priceText: '￥268/盒',
        soldCountText: '月销892',
        badgePrimary: '新品上市'
      } as FeaturedListCard,
      {
        name: '嘉应茗茶 正山小种',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_3.png',
        priceText: '￥188/盒',
        soldCountText: '月销1567'
      } as FeaturedListCard,
      {
        name: '嘉应茗茶 金骏眉',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_4.png',
        priceText: '￥388/盒',
        soldCountText: '月销756',
        badgePrimary: '推荐'
      } as FeaturedListCard,
      {
        name: '嘉应茗茶 白茶饼',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_5.png',
        priceText: '￥298/盒',
        soldCountText: '月销1234'
      } as FeaturedListCard,
      {
        name: '嘉应茗茶 普洱熟茶',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/object/public/product-images/home/home_review_bg_6.png',
        priceText: '￥168/盒',
        soldCountText: '月销2890',
        badgePrimary: '促销'
      } as FeaturedListCard
    ];
  }

  // 缩放函数
  private s(value: number): number {
    return value * this.pageWidth / 375;
  }

  private cardHeight(): number {
    return 245;
  }

  private cardImageHeight(): number {
    return 149;
  }


  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主内容
      Column() {
        // 顶部导航栏
        this.TopBar()

        // 筛选标签栏
        Row() {
          this.FilterTabs()
        }
        .margin({top: 8, bottom: 12})

        // 产品列表
        this.ProductList()
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.cardBackground)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // 顶部导航栏
  @Builder
  TopBar() {
    Column() {
      // 搜索栏
      Row() {
          // 返回按钮
          Image($r('app.media.product_icon_back_3x'))
            .width(20)
            .height(20)
            .fillColor(Color.White)
            .onClick(() => {
              NavService.back();
              this.currentRoute = NavService.getCurrentRoute();
            })

        // 搜索框
        Row() {
          Image($r('app.media.product_icon_search'))
            .width(16)
            .height(16)
            .fillColor('#999999')
            .margin({ right: 8 })

          Text('惠购嘉应茶叶，惊喜好茶')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .height(30)
        .backgroundColor('rgba(255, 255, 255, 0.6)')
        .borderRadius(6)
        .padding({ left: 12, right: 12 })
        .margin({ left: 15, right: 12 })

        // 三个圆点
        Row({ space: 3.5 }) {
          Circle()
            .width(6)
            .height(6)
            .fill(Color.White)
          Circle()
            .width(6)
            .height(6)
            .fill(Color.White)
          Circle()
            .width(6)
            .height(6)
            .fill(Color.White)
        }
      }
      .width('100%')
      .height(30)
      .padding({ left: 18, right: 11 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(81)
    .padding({ top: 41 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#97C9C0', 0], ['#71AD91', 1]]
    })
  }

  // 筛选标签栏
    // 筛选标签栏
    @Builder
    FilterTabs() {
      Row() {
        // 默认
        Stack() {
          if (this.currentFilter === 'default') {
            Image($r('app.media.product_selected_icon'))
              .width(43)
              .height(40)
              .objectFit(ImageFit.Contain)
          }
          
          Text('默认')
            .fontSize(16)
            .fontColor(this.currentFilter === 'default' ? '#2D5A4E' : '#4D716F')
            .fontWeight(this.currentFilter === 'default' ? FontWeight.Medium : FontWeight.Regular)
        }
        .width(43)
        .height(40)
        .alignContent(Alignment.Center)
        .onClick(() => {
          this.currentFilter = 'default';
        })

        Blank().width(29)

          // 销量
          Stack() {
            if (this.currentFilter === 'sales_asc' || this.currentFilter === 'sales_desc') {
              Image($r('app.media.product_selected_icon'))
                .width(43)
                .height(40)
                .objectFit(ImageFit.Contain)
            }
            
            Row({ space: 4 }) {
              Text('销量')
                .fontSize(16)
                .fontColor((this.currentFilter === 'sales_asc' || this.currentFilter === 'sales_desc') ? '#2D5A4E' : '#4D716F')
                .fontWeight((this.currentFilter === 'sales_asc' || this.currentFilter === 'sales_desc') ? FontWeight.Medium : FontWeight.Regular)

              Column() {
                Text('▲')
                  .fontSize(8)
                  .fontColor(this.currentFilter === 'sales_asc' ? '#2D5A4E' : '#4D716F')
                  .opacity(this.currentFilter === 'sales_asc' ? 1 : 0.7)
                Text('▼')
                  .fontSize(8)
                  .fontColor(this.currentFilter === 'sales_desc' ? '#2D5A4E' : '#4D716F')
                  .opacity(this.currentFilter === 'sales_desc' ? 1 : 0.7)
                  .margin({ top: 2 })
              }
            }
          }
          .width(43)
          .height(40)
          .alignContent(Alignment.Center)
          .onClick(() => {
            if (this.currentFilter === 'sales_asc') {
              this.currentFilter = 'sales_desc';
            } else {
              this.currentFilter = 'sales_asc';
            }
          })

        Blank().width(32)

        // 价格
        Stack() {
          if (this.currentFilter === 'price_asc' || this.currentFilter === 'price_desc') {
            Image($r('app.media.product_selected_icon'))
              .width(43)
              .height(40)
              .objectFit(ImageFit.Contain)
          }
          
          Row({ space: 4 }) {
            Text('价格')
              .fontSize(16)
              .fontColor((this.currentFilter === 'price_asc' || this.currentFilter === 'price_desc') ? '#2D5A4E' : '#4D716F')
              .fontWeight((this.currentFilter === 'price_asc' || this.currentFilter === 'price_desc') ? FontWeight.Medium : FontWeight.Regular)

            Column() {
              Text('▲')
                .fontSize(8)
                .fontColor(this.currentFilter === 'price_asc' ? '#2D5A4E' : '#4D716F')
                .opacity(this.currentFilter === 'price_asc' ? 1 : 0.7)
              Text('▼')
                .fontSize(8)
                .fontColor(this.currentFilter === 'price_desc' ? '#2D5A4E' : '#4D716F')
                .opacity(this.currentFilter === 'price_desc' ? 1 : 0.7)
                .margin({ top: 2 })
            }
          }
        }
        .width(43)
        .height(40)
        .alignContent(Alignment.Center)
        .onClick(() => {
          if (this.currentFilter === 'price_asc') {
            this.currentFilter = 'price_desc';
          } else {
            this.currentFilter = 'price_asc';
          }
        })

        Blank().width(26)

        // 新品
        Stack() {
          if (this.currentFilter === 'new') {
            Image($r('app.media.product_selected_icon'))
              .width(43)
              .height(40)
              .objectFit(ImageFit.Contain)
          }
          
          Text('新品')
            .fontSize(16)
            .fontColor(this.currentFilter === 'new' ? '#2D5A4E' : '#4D716F')
            .fontWeight(this.currentFilter === 'new' ? FontWeight.Medium : FontWeight.Regular)
        }
        .width(43)
        .height(40)
        .alignContent(Alignment.Center)
        .onClick(() => {
          this.currentFilter = 'new';
        })

        Blank()

        // 筛选图标
        Image($r('app.media.product_icon_filter_3x'))
          .width(this.s(20))
          .height(this.s(20))
          .fillColor('#4D716F')

        //排列图标
        Image($r('app.media.product_icon_arrangement'))
          .width(this.s(20))
          .height(this.s(20))
          .fillColor('#4D716F')
          .margin({ left: 5})
      }
      .width('100%')
      .padding({ left: 21, right: 21 })
      .height(40)
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)
    }

    // 产品列表
    @Builder
    ProductList() {
    Scroll() {
      Column() {
        // 产品网格
        Grid() {
            ForEach(this.products, (card: FeaturedListCard) => {
              GridItem() {
                ProductCard({
                  card: card,
                  onCardClick: () => {
                    this.currentRoute = AppRoute.PRODUCT_DETAIL;
                    NavService.go(AppRoute.PRODUCT_DETAIL);
                  }
                })
                }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      }
      .width('100%')
      .padding({ bottom: 80 })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }

}
