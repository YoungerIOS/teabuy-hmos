import { AppRoute } from '../../../router/RouteMap';

@Component
export struct ProfilePage {
  @Link currentRoute: AppRoute;
  @State private contentWidth: number = 375;
  @State private orderCount: number = 0;
  @State private favoriteCount: number = 0;
  @State private followCount: number = 0;
  private readonly baseWidth: number = 375;
  private readonly navOverlayHeight: number = 104;

  private s(value: number): number {
    return value * this.contentWidth / this.baseWidth;
  }

  private topPatternHeight(): number {
    return this.contentWidth * 402 / 1371;
  }

  private bottomPatternHeight(): number {
    return this.contentWidth * 804 / 1677;
  }

  private bottomPatternY(): number {
    return this.s(560) + this.bottomPatternHeight() * 0.2;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#71AD91');

      // Top textured rectangle background (full width, proportional height).
      Image($r('app.media.home_new_tea_card_pattern'))
        .width('100%')
        .height(this.topPatternHeight())
        .objectFit(ImageFit.Fill)
        .position({ x: 0, y: this.s(122) });

      // Light lower background region.
      Column()
        .width('100%')
        .height(this.s(582))
        .backgroundColor('#F2F7F0')
        .position({ x: 0, y: this.s(230) });

      Image($r('app.media.profile_pattern_bottom_3x'))
        .width('100%')
        .height(this.bottomPatternHeight())
        .objectFit(ImageFit.Fill)
        .position({ x: 0, y: this.bottomPatternY() })
        .scale({ x: 1.4, y: 1.4, centerX: '50%', centerY: '50%' })
        .opacity(0.7);

      Column() {
        this.TopProfileArea();
        this.OrderSummaryArea();
        Row() {
          this.SigninArea();
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);

        Row() {
          this.InterestRow(0);
        }
        .margin({ top: this.s(30) });

        Row() {
          this.DashedSeparator();
        }
        .margin({ top: this.s(19), left: this.s(23.5) });

        Row() {
          this.InterestRow(1);
        }
        .margin({ top: this.s(15) });

        Row() {
          this.DashedSeparator();
        }
        .margin({ top: this.s(19), left: this.s(23.5) });

        Row() {
          this.InterestRow(2);
        }
        .margin({ top: this.s(15) });

        Blank()
          .height(this.navOverlayHeight);
      }
      .width('100%')
      .height('100%');

    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue, newValue) => {
      void oldValue;
      const width = Number(newValue.width);
      if (width > 0) {
        this.contentWidth = width;
      }
    });
  }

  @Builder
  private TopProfileArea() {
    Row() {
      Row() {
        Image($r('app.media.profile_icon_message_3x'))
          .width(this.s(24))
          .height(this.s(24))
          .objectFit(ImageFit.Contain);
        Row()
          .width(this.s(8))
          .height(this.s(8))
          .borderRadius(this.s(4))
          .backgroundColor('#D85E53')
          .position({ x: this.s(18), y: this.s(2) });
      }
      .width(this.s(36))
      .height(this.s(36))
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
      });

      Column() {
        Image($r('app.media.profile_avatar_3x'))
          .width(this.s(68))
          .height(this.s(68))
          .objectFit(ImageFit.Cover)
          .borderRadius(this.s(34));

        Text('嘉心糖是吗')
          .fontSize(this.s(16))
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .margin({ top: this.s(8) });

        Row() {
          Image($r('app.media.profile_icon_edit_3x'))
            .width(this.s(14))
            .height(this.s(14))
            .objectFit(ImageFit.Contain);
          Text('修改签名')
            .fontSize(this.s(10))
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ left: this.s(4) });

          Column()
            .width(1)
            .height(this.s(10))
            .backgroundColor('rgba(255,255,255,0.7)')
            .margin({ left: this.s(10), right: this.s(10) });

          Text('成长值 114')
            .fontSize(this.s(10))
            .fontColor('rgba(255,255,255,0.7)');
          Image($r('app.media.profile_icon_arrow_3x'))
            .width(this.s(11))
            .height(this.s(11))
            .objectFit(ImageFit.Contain)
            .margin({ left: this.s(6) });
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ top: this.s(6) });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: this.s(7) });

      Row() {
        Image($r('app.media.profile_icon_setting_3x'))
          .width(this.s(24))
          .height(this.s(24))
          .objectFit(ImageFit.Contain);
      }
      .width(this.s(36))
      .height(this.s(36))
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
      });
    }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .padding({ left: this.s(20), right: this.s(20), top: this.s(44) });
  }

  @Builder
  private OrderSummaryArea() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.profile_top_summary_3x'))
          .width(this.s(338))
          .height(this.s(113))
          .objectFit(ImageFit.Fill);

        Row() {
          this.OrderMetric(this.orderCount, '订单');
          this.OrderMetric(this.favoriteCount, '收藏');
          this.OrderMetric(this.followCount, '关注');
        }
        .width(this.s(338))
        .justifyContent(FlexAlign.SpaceEvenly)
        .offset({x: 0, y: 10})
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: this.s(12) });
  }

  @Builder
  private OrderMetric(value: number, label: string) {
    Column() {
      Text(label)
        .fontSize(this.s(14))
        .fontColor('#FFFFFF')
        .margin({ top: this.s(6) });
      Text(value.toString())
        .fontSize(this.s(24))
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .margin({ top: this.s(5) });
    }
    .width(this.s(112))
    .height(this.s(113))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private SigninArea() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.profile_signin_title_icon_3x'))
            .width(this.s(20))
            .height(this.s(20))
            .objectFit(ImageFit.Contain);
          Text('茶豆114粒')
            .fontSize(this.s(16))
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .margin({ left: this.s(6) });
        }
        Blank();
        Row() {
          Text('签到')
            .fontSize(this.s(16))
            .fontColor('#FFFFFF');
        }
        .height(this.s(28))
        .padding({ left: this.s(22), right: this.s(22) })
        .backgroundColor('#D85E53')
        .borderRadius(this.s(14));
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      Text('连续签到7天获得双倍奖励')
        .fontSize(this.s(10))
        .fontColor('rgba(255,255,255,0.7)')
        .width('100%')
        .margin({ top: this.s(3) });

      Stack({ alignContent: Alignment.TopStart }) {
        Divider()
          .width(this.s(281.8))
          .strokeWidth(1)
          .color('rgba(255,255,255,0.2)')
          .position({ x: 0, y: this.s(9) });

        Row() {
          ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
            this.SignDayItem(day, day === 1);
          }, (day: number) => day.toString());
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .position({ x: 0, y: 0 });
      }
      .width(this.s(281.8))
      .height(this.s(36))
      .margin({ top: this.s(8) });
    }
    .width(this.s(336))
    .height(this.s(113))
    .padding({ left: this.s(14), right: this.s(14), top: this.s(10), bottom: this.s(10) })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#96C9C0', 0], ['#71AD91', 1]]
    })
    .borderRadius(this.s(8))
    .shadow({
      radius: this.s(8),
      offsetX: 0,
      offsetY: this.s(4),
      color: '#26000000'
    })
    .margin({ top: this.s(20) });
  }

  @Builder
  private SignDayItem(day: number, active: boolean) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.s(18))
          .height(this.s(18))
          .borderRadius(this.s(9))
          .backgroundColor(active ? '#D85E53' : 'rgba(255,255,255,0.2)');

        Image($r('app.media.profile_signin_leaf_3x'))
          .width(this.s(10))
          .height(this.s(10))
          .objectFit(ImageFit.Contain);
      }
      .width(this.s(20))
      .height(this.s(20));

      Text(`Day${day}`)
        .fontSize(this.s(8))
        .fontColor('#FFFFFF')
        .margin({ top: this.s(8) });
    }
    .width(this.s(20))
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private InterestRow(index: number) {
    Row() {
      Image(index === 0 ? $r('app.media.profile_interest_avatar_1_3x')
        : (index === 1 ? $r('app.media.profile_interest_avatar_1_3x') : $r('app.media.profile_interest_avatar_2_3x')))
        .width(this.s(58))
        .height(this.s(58))
        .objectFit(ImageFit.Cover)
        .borderRadius(this.s(29));

      Column() {
        Text(index === 0 ? '兴趣精选' : (index === 1 ? '活动精选' : '茶道专享'))
          .fontSize(this.s(16))
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333');
        Text(index === 0 ? '收到新的活动推荐' : (index === 1 ? '收到新的活动推荐' : '茶艺学习共享平台，随时......'))
          .fontSize(this.s(12))
          .fontColor('#666666')
          .margin({ top: this.s(4) });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.s(10) });

      Text('2023/4   19:55')
        .fontSize(this.s(12))
        .fontColor('#666666')
        .margin({ top: this.s(-14) });
    }
    .width('100%')
    .padding({ left: this.s(22), right: this.s(15) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private DashedSeparator() {
    Row()
      .width(this.s(337.5))
      .height(0.1)
      .border({
        width: 1,
        color: '#4D716F',
        style: BorderStyle.Dashed
      })
      .opacity(0.2);
  }
}
