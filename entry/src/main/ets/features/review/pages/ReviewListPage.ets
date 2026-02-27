import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../../../core/ui/theme/Tokens';

class ReviewTimelineItem {
  title: string = '';
  imageUrl: string = '';
  side: 'left' | 'right' = 'left';
  y: number = 0;
  avatar: number = 56;
  textWidth: number = 110;
}

@Component
export struct ReviewListPage {
  @Prop teaName: string = '绿茶';
  @Link currentRoute: AppRoute;

  private readonly statusBarMaskHeight: number = 44;
  private readonly headerTopInset: number = 56;
  private readonly headerHeight: number = 52;
  private readonly cloudLeftX: number = 42;
  private readonly cloudLeftY: number = 385;
  private readonly cloudRightX: number = 236;
  private readonly cloudRightY: number = 481;
  private readonly baseTop: number = 156;
  private readonly reviewItems: ReviewTimelineItem[] = [
    { title: '碧螺春', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_3.png?width=220&quality=72', side: 'left', y: 0, avatar: 64, textWidth: 120 },
    { title: '六师绿茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_2.png?width=220&quality=72', side: 'right', y: 58, avatar: 76, textWidth: 120 },
    { title: '高山绿茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_5.png?width=220&quality=72', side: 'left', y: 130, avatar: 72, textWidth: 128 },
    { title: '银针绿茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_4.png?width=220&quality=72', side: 'right', y: 206, avatar: 94, textWidth: 128 },
    { title: '炒青绿茶', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_6.png?width=220&quality=72', side: 'left', y: 286, avatar: 70, textWidth: 128 },
    { title: '白毛豪尖', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_7.png?width=220&quality=72', side: 'right', y: 372, avatar: 82, textWidth: 126 },
    { title: '碧螺春', imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_1.png?width=220&quality=72', side: 'left', y: 458, avatar: 62, textWidth: 120 }
  ];

  @Builder
  private ReviewNode(item: ReviewTimelineItem) {
    Row() {
      if (item.side === 'right') {
        Blank().layoutWeight(1);
      }

      if (item.side === 'left') {
        Row({ space: 10 }) {
          Image(item.imageUrl)
            .width(item.avatar)
            .height(item.avatar)
            .borderRadius(item.avatar / 2)
            .objectFit(ImageFit.Cover)
            .border({ width: 2, color: '#D8E4D8' });

          Column({ space: 4 }) {
            Text(item.title)
              .fontSize(24)
              .fontColor('#F5F8F5')
              .fontWeight(FontWeight.Medium);
            Row()
              .width(item.textWidth)
              .height(1)
              .backgroundColor('#EAF4EA')
              .opacity(0.62);
          }
          .width(item.textWidth)
          .alignItems(HorizontalAlign.Start);
        }
      } else {
        Row({ space: 10 }) {
          Column({ space: 4 }) {
            Text(item.title)
              .fontSize(24)
              .fontColor('#F5F8F5')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.End)
              .width(item.textWidth);
            Row()
              .width(item.textWidth)
              .height(1)
              .backgroundColor('#EAF4EA')
              .opacity(0.62);
          }
          .alignItems(HorizontalAlign.End);

          Image(item.imageUrl)
            .width(item.avatar)
            .height(item.avatar)
            .borderRadius(item.avatar / 2)
            .objectFit(ImageFit.Cover)
            .border({ width: 2, color: '#D8E4D8' });
        }
      }

      if (item.side === 'left') {
        Blank().layoutWeight(1);
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .position({ x: 0, y: this.baseTop + item.y });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#78B59A');

      Column() {
        Image($r('app.media.review_pattern_top'))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .opacity(0.62);
      }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start);

      Row()
        .width('100%')
        .height(this.statusBarMaskHeight)
        .backgroundColor('#78B59A')
        .position({ x: 0, y: 0 });

      Column() {
        Image($r('app.media.review_pattern_bottom'))
          .width('100%')
          .height(188)
          .objectFit(ImageFit.Cover)
          .opacity(0.56)
          .translate({ x: 0, y: 30 });
      }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End);

      Image($r('app.media.review_cloud_left'))
        .width(81)
        .height(49)
        .objectFit(ImageFit.Contain)
        .opacity(0.9)
        .position({ x: this.cloudLeftX, y: this.cloudLeftY });

      Image($r('app.media.review_cloud_right'))
        .width(78)
        .height(40)
        .objectFit(ImageFit.Contain)
        .opacity(0.9)
        .position({ x: this.cloudRightX, y: this.cloudRightY });

      Row() {
        Row()
          .width(1)
          .height('100%')
          .backgroundColor('#E9F2E8')
          .opacity(0.22);
      }
      .width('100%')
      .height('73%')
      .justifyContent(FlexAlign.Center)
      .position({ x: 0, y: 104 });

      Row() {
        Row() {
          Text('‹')
            .fontSize(28)
            .fontColor(Colors.cardBackground);
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.currentRoute = AppRoute.HOME;
            NavService.go(AppRoute.HOME);
          });
        Blank();
        Text(`茶评/${this.teaName}`)
          .fontSize(20)
          .fontColor(Colors.cardBackground)
          .fontWeight(FontWeight.Medium);
        Blank();
        Row().width(44).height(44);
      }
      .width('100%')
      .height(this.headerHeight)
      .padding({ left: 12, right: 12 })
      .alignItems(VerticalAlign.Center)
      .position({ x: 0, y: this.headerTopInset });

      ForEach(this.reviewItems, (item: ReviewTimelineItem) => {
        this.ReviewNode(item);
      }, (item: ReviewTimelineItem) => item.title + item.y);
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
