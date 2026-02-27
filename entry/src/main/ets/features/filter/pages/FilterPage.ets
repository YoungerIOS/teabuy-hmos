import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../../../core/ui/theme/Tokens';
import { window } from '@kit.ArkUI';
import { BannerCarousel } from '../../../core/ui/components/BannerCarousel';

@Component
export struct FilterPage {
  @Link currentRoute: AppRoute;
  @State selectedCategoryIndex: number = 5; // "茶区" by default matching design

  @State topSafeAreaPx: number = 0;

  private readonly categories: string[] = [
    '热门推荐', '年份', '品牌', '包茶', '茶具', '茶区', '袋茶', '茶制品'
  ];

  @State private bannerImages: string[] = [
    'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_banner_1.png?width=900&quality=72',
    'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_banner_2.png?width=900&quality=72',
    'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_banner_1.png?width=900&quality=72'
  ];

  aboutToAppear() {
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topSafeAreaPx = px2vp(avoidArea.topRect.height);
    }).catch(() => {
      this.topSafeAreaPx = 44; // fallback for previewer
    });
  }

  build() {
    Column() {
      // Main Content Split
      Row() {
        // Left Side Navigation
        Column() {
          List() {
            ForEach(this.categories, (item: string, index: number) => {
              ListItem() {
                Row() {
                  if (this.selectedCategoryIndex === index) {
                    Column()
                      .width(3)
                      .height(18)
                      .backgroundColor('#97C9C0')
                      .borderRadius(1.5)
                      .margin({ right: 6 });
                  } else {
                    Row().width(9);
                  }
                  
                  Text(item)
                    .fontSize(this.selectedCategoryIndex === index ? 20 : 16)
                    .fontColor(Color.White)
                    .fontWeight(this.selectedCategoryIndex === index ? FontWeight.Bold : FontWeight.Normal)
                    .layoutWeight(1);
                }
                .width('100%')
                .height(60)
                .onClick(() => {
                  this.selectedCategoryIndex = index;
                })
              }
            }, (item: string) => item)
          }
          .divider({
            strokeWidth: 1,
            color: 'rgba(255, 255, 255, 0.15)',
            startMargin: 16,
            endMargin: 16
          })
          .width('100%')
          .height('100%')
          .padding({ top: 10, bottom: 10 });
        }
        .width(110)
        .height('100%')
        .backgroundImage($r('app.media.filter_sidebar_texture'))
        .backgroundImageSize({ width: '100%', height: '100%' })
        .borderRadius(8);

        // Right Side Content
        Column() {
          // Top Search Bar Area
          Row({ space: 12 }) {
            Row() {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(16)
                .fontColor([Colors.textSecondary])
                .margin({ right: 8 });
              Text('惠购嘉应茶叶，惊喜好茶')
                .fontSize(12)
                .fontColor(Colors.textSecondary);
              Blank();
              SymbolGlyph($r('sys.symbol.camera'))
                .fontSize(16)
                .fontColor([Colors.textSecondary]);
            }
            .layoutWeight(1)
            .height(38)
            .backgroundColor('rgba(69, 103, 101, 0.06)')
            .borderRadius(20)
            .padding({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center);
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 });

          Scroll() {
            Column({ space: 20 }) {
              
              // 轮播图 Section
              BannerCarousel({
                bannerImages: this.bannerImages,
                bannerWidth: 260, // Adjusted width for side-panel layout
                bannerHeight: 120, // Adjusted height constraint
                autoPlayInterval: 3400,
                carouselId: 'filter_banner'
              })
              .margin({ left: 16, right: 16 });

              // 品种 Section
              Column() {
                Row() {
                  Column().width(3).height(12).backgroundColor('#4D716F').borderRadius(1.5).margin({ right: 6 });
                  Text('品种').fontSize(14).fontColor('#4D716F').fontWeight(FontWeight.Medium);
                }
                .width('100%')
                .margin({ bottom: 12 });

                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                  this.CategoryItem('绿茶', $r('app.media.filter_cat_green_tea'))
                  this.CategoryItem('红茶', $r('app.media.filter_cat_black_tea'))
                  this.CategoryItem('黑茶', $r('app.media.filter_cat_black_tea'))
                  this.CategoryItem('花茶', $r('app.media.filter_cat_oolong_tea'))
                  this.CategoryItem('白茶', $r('app.media.filter_cat_white_tea'))
                  Row().width(70) // Placeholder to balance flex
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 });

              // 热门推荐 Section
              Column() {
                Row() {
                  Column().width(3).height(12).backgroundColor('#4D716F').borderRadius(1.5).margin({ right: 6 });
                  Text('热门推荐').fontSize(14).fontColor('#4D716F').fontWeight(FontWeight.Medium);
                }
                .width('100%')
                .margin({ bottom: 12 });

                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                  this.CategoryItem('银针绿茶', $r('app.media.filter_cat_green_tea'))
                  this.CategoryItem('碧螺春', $r('app.media.filter_cat_green_tea'))
                  this.CategoryItem('白毛豪尖', $r('app.media.filter_cat_white_tea'))
                  
                  this.CategoryItem('炒青绿茶', $r('app.media.filter_cat_green_tea'))
                  this.CategoryItem('宗师绿茶', $r('app.media.filter_cat_green_tea'))
                  this.CategoryItem('铁观音', $r('app.media.filter_cat_oolong_tea'))
                  
                  this.CategoryItem('竹叶青', $r('app.media.filter_cat_green_tea'))
                  this.CategoryItem('嘉应红茶', $r('app.media.filter_cat_black_tea'))
                  this.CategoryItem('普洱茶', $r('app.media.filter_cat_black_tea'))
                  
                  this.CategoryItem('乌龙茶', $r('app.media.filter_cat_oolong_tea'))
                  this.CategoryItem('菊花茶', $r('app.media.filter_cat_white_tea'))
                  Row().width(70) // balance third item
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16 });
            }
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off);
        }
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 12, topRight: 0, bottomLeft: 0, bottomRight: 0 })
        .height('100%');
      }
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topSafeAreaPx })
    .backgroundColor('#F2F7F0')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  private CategoryItem(title: string, imageSrc?: Resource) {
    Column({ space: 8 }) {
      if (imageSrc) {
        Image(imageSrc)
          .width(56)
          .height(56)
          .objectFit(ImageFit.Contain)
          .borderRadius(28); // assuming circular exported design elements
      } else {
        // Fallback or empty placeholder area
        Row()
          .width(56)
          .height(56)
          .backgroundColor('#F2F7F0')
          .borderRadius(28);
      }
      
      Text(title)
        .fontSize(12)
        .fontColor(Colors.textPrimary)
        .textAlign(TextAlign.Center);
    }
    .width(70)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Center);
  }
}
