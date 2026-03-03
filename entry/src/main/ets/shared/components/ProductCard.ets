/**
 * 产品卡片组件
 * 优化后的卡片样式
 */

import { Colors } from '../../core/ui/theme/Tokens';
import { FeaturedListCard } from '../../features/home/data/HomeRepository';

@Component
export struct ProductCard {
  @Prop card: FeaturedListCard = {} as FeaturedListCard;
  @Prop cardWidth: number = 161;
  @Prop cardHeight: number = 245;
  @Prop cardImageHeight: number = 149;
  onAddToCart?: () => void;
  onCardClick?: () => void;

  build() {
    Column() {
      // 产品图片
      if (this.card.imageUrl && this.card.imageUrl.length > 0) {
        Image(this.card.imageUrl)
          .width(this.cardWidth)
          .height(this.cardImageHeight)
          .borderRadius({ topLeft: 6, topRight: 6 })
          .objectFit(ImageFit.Cover);
      } else {
        Row()
          .width(this.cardWidth)
          .height(this.cardImageHeight)
          .borderRadius({ topLeft: 6, topRight: 6 })
          .backgroundColor(Colors.newTeaCardBackground);
      }

      // 产品信息
      Column({ space: 2 }) {
        // 产品名称 + 销量 (使用 Stack 堆叠)
        Stack({ alignContent: Alignment.TopStart }) {
          // 产品名称 (占据整行,从顶部开始)
          Text(this.card.name || '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4D716F')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 11 });

          // 销量 (定位在右侧,比产品名称第2行略低)
          if (this.card.soldCountText && this.card.soldCountText.length > 0) {
            Row() {
              Blank();
              Text(this.card.soldCountText)
                .fontSize(10)
                .fontColor('#999999');
            }
            .width('100%')
            .margin({ top: 29 });
          }
        }
        .width('100%')
        .height(38);

        // 增加间距
        Row()
          .height(5);

        // 价格 + 购物车按钮 (固定位置)
        Row() {
          if (this.card.priceText && this.card.priceText.length > 0) {
            Text(this.card.priceText)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D85E53');
          }

          Blank();

          Image($r('app.media.nav_third_icon_only_active'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              if (this.onAddToCart) {
                this.onAddToCart();
              }
            });
        }
        .width('100%')
        .height(20)
        .padding({right: 5})
        .alignItems(VerticalAlign.Center);


        // 标签 (固定位置)
        Row({ space: 4 }) {
          if (this.card.badgePrimary && this.card.badgePrimary.length > 0) {
            Row() {
              Text(this.card.badgePrimary)
                .fontSize(9)
                .fontColor(Colors.cardBackground);
            }
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .borderRadius(2)
            .backgroundColor('#71AD91');
          }
          if (this.card.badgeSecondary && this.card.badgeSecondary.length > 0) {
            Row() {
              Text(this.card.badgeSecondary)
                .fontSize(9)
                .fontColor(Colors.cardBackground);
            }
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .borderRadius(2)
            .backgroundColor('#71AD91');
          }
        }
        .width('100%')
        .height(16)
        .justifyContent(FlexAlign.Start);
      }
      .padding({ left: 6, right: 6, bottom: 3 })
      .layoutWeight(1);
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .backgroundColor(Colors.cardBackground)
    .borderRadius(6)
    .margin({ bottom: 12 })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    });
  }
}
