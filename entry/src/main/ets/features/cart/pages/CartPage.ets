import { AppRoute } from '../../../router/RouteMap';
import { Colors } from '../../../core/ui/theme/Tokens';
import { CartItem } from '../data/CartRepository';
import { FeaturedListCard } from '../../home/data/HomeRepository';

@Component
export struct CartPage {
  @Link currentRoute: AppRoute;
  @StorageLink('cartItems') cartItems: CartItem[] = [];

  // TODO: we should pull actual content width or just define it.
  @State private homeContentWidth: number = 375;
  @State private activeDeletePopupIndex: number = -1;

  private cartScale(value: number): number {
    return value * this.homeContentWidth / 375;
  }

  private getRecommendProducts(): FeaturedListCard[] {
    const items: FeaturedListCard[] = [];
    const names = ['客家红茶小专区', '客家乌龙茶', '客家红茶小专区', '客家乌龙茶'];
    const prices = ['￥181/盒', '￥114/盒', '￥181/盒', '￥114/盒'];
    for (let i = 0; i < 4; i++) {
      const card = new FeaturedListCard();
      card.name = names[i];
      card.priceText = prices[i];
      card.imageUrl = '';
      items.push(card);
    }
    return items;
  }

  @Builder
  private DeletePopup(index: number) {
    Row() {
      Text('删除')
        .fontSize(this.cartScale(14))
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width(this.cartScale(64))
    .height(this.cartScale(32))
    .backgroundColor('#FF4D4F')
    .borderRadius(this.cartScale(6))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.removeItem(index);
      this.activeDeletePopupIndex = -1;
    })
  }

  @Builder
  private EmptyCartState() {
    Scroll() {
      Column() {
        // Empty cart graphic or symbol
        Image($r('app.media.ic_empty_cart'))
          .width(this.cartScale(340))
          .height(this.cartScale(196))
          .objectFit(ImageFit.Contain)
          .margin({ top: this.cartScale(80), bottom: this.cartScale(24) });

        Text('购物车竟然是空的~')
          .fontSize(this.cartScale(16))
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium);

        Text('当前购物车尚未推荐商品，快去选购商品吧~')
          .fontSize(this.cartScale(12))
          .fontColor('#999999')
          .margin({ top: this.cartScale(12), bottom: this.cartScale(32) });

        Button('去逛逛')
          .width(this.cartScale(120))
          .height(this.cartScale(36))
          .fontSize(this.cartScale(14))
          .fontColor(Colors.brandAccent)
          .backgroundColor(Colors.cardBackground)
          .border({ width: 1, color: Colors.brandAccent, radius: this.cartScale(18) })
          .onClick(() => {
            this.currentRoute = AppRoute.HOME;
          });

        // Recommend section in empty cart
        this.RecommendSection();
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ left: this.cartScale(16), right: this.cartScale(16), bottom: this.cartScale(20) });
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor('#F5F5F5');
  }

  private getTotalPrice(): number {
    return this.cartItems.reduce((sum: number, item: CartItem) => {
      if (!item.selected) return sum;
      const priceStr = item.product.priceText || '0';
      const match = priceStr.match(/\d+(\.\d+)?/);
      const priceVal = match ? parseFloat(match[0]) : 0;
      return sum + (priceVal * item.quantity);
    }, 0);
  }

  private getTotalSelectedCount(): number {
    return this.cartItems.reduce((sum: number, item: CartItem) => sum + (item.selected ? item.quantity : 0), 0);
  }

  private getAllSelected(): boolean {
    return this.cartItems.length > 0 && this.cartItems.every(item => item.selected);
  }

  private toggleAll(selected: boolean) {
    const updated = this.cartItems.map(item => {
      item.selected = selected;
      return item;
    });
    AppStorage.setOrCreate('cartItems', [...updated]);
  }

  private updateItemCount(index: number, delta: number) {
    let updated = [...this.cartItems];
    const newQty = updated[index].quantity + delta;
    if (newQty <= 0) {
      updated.splice(index, 1);
    } else {
      updated[index].quantity = newQty;
    }
    AppStorage.setOrCreate('cartItems', updated);
  }

  private toggleItemSelection(index: number) {
    let updated = [...this.cartItems];
    updated[index].selected = !updated[index].selected;
    AppStorage.setOrCreate('cartItems', updated);
  }

  private removeItem(index: number) {
    let updated = [...this.cartItems];
    updated.splice(index, 1);
    AppStorage.setOrCreate('cartItems', updated);
  }

  @Builder
  private CartItemCard(item: CartItem, index: number) {
    Row() {
      // Main Card (Green Theme) wrapped in Stack for shadow
      Stack({ alignContent: Alignment.Bottom }) {
        // Shadow Bar
        Row()
          .width('88%')
          .height(this.cartScale(20))
          .backgroundColor('#4D716F')
          .opacity(0.5)
          .borderRadius(this.cartScale(6))
          .margin({ bottom: this.cartScale(-6) });

        Row({ space: this.cartScale(14) }) {
          // Product Image
          if (item.product.imageUrl) {
            Image(item.product.imageUrl)
              .width(this.cartScale(103))
              .height(this.cartScale(103))
              .borderRadius(this.cartScale(6))
              .objectFit(ImageFit.Cover);
          } else {
            Row()
              .width(this.cartScale(103))
              .height(this.cartScale(103))
              .borderRadius(this.cartScale(6))
              .backgroundColor('#EFEFEF');
          }

          // Details
          Column() {
            Row() {
              Text(item.product.name || item.product.title || '商品')
                .fontSize(this.cartScale(16))
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.cardBackground)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1);
              
              // Settings/Delete Icon
              Image('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAARzQklUCAgICHwIZIgAAAM1SURBVHic7ZvtkZswEIZXqcAlqIO4BEpwB6GE6yCkgiuBSQVOB6QDuwNIBU4Hb34AZ46sHK2QFt9knxnPzWDvh4S0u1o4IsMwDMMwDMMwDMN4MpymMQBHIjpkUHV1zv3OoGd/AHgALfJyA3Dae2ybAdBknpglF40xfCqlGEBDRF9L6Seij7vFAFQFVw4A9BjjWXGyB2kAByK6EJFffTUQ0bfp71Y+bpAGH3cu08SVtOunlVvUziYAHDBmmDVVYbunha2b1vYTAz6dvyrYPa9jVGmbYsAH5pvGkgfQMbbr0nZFBJxslGzXjO0egNew/09CDir7sN5mANBq+hBybJfAzPjhGR+w+yoCn9a7nXxpGV/Oe/gyO+QDq8cn6DoAOGIM9kn1zORPz/hTS3VlARkC8zQZXWCiOwi3Kp4gHs6ObE7r4LcntwIaoW+bdWwm4MSLQH45OResthXG7dYtfhNdcD64eV44zDQAvDAORAdmvM84Dwe+mshKYKNlfNRJ+9MdX1MJ5Gfno2LDYiWl3oQlPlZHEhiXfvKdwZitZqLapni/ZbzAFhfj6lh5orSOIndS/p4of40RcM79pHsHsRLY+sFc+yyQT5ogz1yLGuga59wg+Lm4QeacuzJyXqIjZYIG5pqk//LmsDAezL+NnqhJ/7rsGAQ2s03Ql0T5KkZglQA4+yFq5tovgXwa4GsgL5Cfs1KPiMJyYS+6IgZ/iFbpT4XqoOhD4SornUOTOw3yNSUDreRmmlj5zQRWUS2QX6bgHuMZ6jh95zH2mZc2clTSeg19ZDgUIv7JaysZHPhDdPQxKBsBRxqhjhp8ZY7pei3Ud2L07NKfCpXzSYdC3LdVPX1SdBzAb/1Kqisb2PNQ+Lcv3Jbdty+NcBfP7+AHl9ZV/Qg5t3sXD/xTjUbTh4cEVlGtZJtL6z2e6Tk9+OyhsorAZ9NKw7YI8AG7KWxzU3dTFSh38RB+aPmcb3cQ6aZa8Oet4m+TbALhYu2c685ibPu2jA3d81Yq4NO+BvrnrVRQ9hVgjufeWhzgY4RNzhLcn72XoEPhYlTtfzUwpvr5s5WBiAbhUxHDMAzDMAzDMAzDMP4L/gANQEhceWVm4wAAAABJRU5ErkJggg==')
                .width(this.cartScale(24))
                .height(this.cartScale(24))
                .fillColor(Colors.cardBackground)
                .margin({ left: this.cartScale(8) })
                .onClick(() => {
                  this.activeDeletePopupIndex = this.activeDeletePopupIndex === index ? -1 : index;
                })
                .bindPopup(this.activeDeletePopupIndex === index, {
                  builder: () => { this.DeletePopup(index); },
                  placement: Placement.Bottom,
                  popupColor: Color.Transparent,
                  enableArrow: false,
                  onStateChange: (e) => {
                    if (!e.isVisible && this.activeDeletePopupIndex === index) {
                      this.activeDeletePopupIndex = -1;
                    }
                  }
                });
            }
            .width('100%')
            .alignItems(VerticalAlign.Top);
              
            Text(item.product.subtitle || 'English title')
              .fontSize(this.cartScale(10))
              .fontColor(Colors.cardBackground)
              .opacity(0.7)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: this.cartScale(2) });

            Row({ space: this.cartScale(4) }) {
              if (item.product.badgePrimary) {
                Text(item.product.badgePrimary)
                  .fontSize(this.cartScale(10))
                  .fontColor(Colors.cardBackground)
                  .backgroundColor('#97C9C0')
                  .border({ width: 1, color: '#4D716F', radius: 2 })
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 });
              }
              if (item.product.badgeSecondary) {
                Text(item.product.badgeSecondary)
                  .fontSize(this.cartScale(10))
                  .fontColor(Colors.cardBackground)
                  .backgroundColor('#97C9C0')
                  .border({ width: 1, color: '#4D716F', radius: 2 })
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 });
              }
            }
            .margin({ top: this.cartScale(6) });

            Blank();

            Row() {
              Text(item.product.priceText || '￥0.00')
                .fontSize(this.cartScale(18)) // Larger font
                .fontWeight(FontWeight.Bold) // Bolder font
                .fontColor(Colors.cardBackground);
              
              Blank();

              // Quantity Control (Capsule bordered style)
              Row() {
                Text('-')
                  .width(this.cartScale(28))
                  .height(this.cartScale(16))
                  .textAlign(TextAlign.Center)
                  .fontSize(this.cartScale(14))
                  .fontColor(Colors.cardBackground)
                  .border({ width: 1, color: Colors.cardBackground, radius: 8 })
                  .onClick(() => this.updateItemCount(index, -1));

                Text(`${item.quantity}`)
                  .width(this.cartScale(24))
                  .textAlign(TextAlign.Center)
                  .fontSize(this.cartScale(14))
                  .fontColor(Colors.cardBackground);

                Text('+')
                  .width(this.cartScale(28))
                  .height(this.cartScale(16))
                  .textAlign(TextAlign.Center)
                  .fontSize(this.cartScale(14))
                  .fontColor(Colors.cardBackground)
                  .border({ width: 1, color: Colors.cardBackground, radius: 8 })
                  .onClick(() => this.updateItemCount(index, 1));
              }
            }
            .width('100%')
            .alignItems(VerticalAlign.Bottom)
            .margin({ bottom: this.cartScale(4) }); // shifted up slightly
          }
          .layoutWeight(1)
          .height(this.cartScale(103))
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .padding(this.cartScale(12))
        .backgroundColor('#71AD91')
        .backgroundImage($r('app.media.home_new_tea_card_pattern'), ImageRepeat.NoRepeat)
        .backgroundImageSize({ width: '100%', height: '100%' })
        .borderRadius(this.cartScale(8));
      }
      .layoutWeight(1);
    }
    .width('100%')
    .margin({ top: this.cartScale(12), bottom: this.cartScale(12) }) // Added bottom space to avoid shadow clipping
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private RecommendCard(product: FeaturedListCard) {
    Column() {
      // Product image area
      Stack() {
        if (product.imageUrl) {
          Image(product.imageUrl)
            .width('100%')
            .height(this.cartScale(120))
            .objectFit(ImageFit.Cover)
            .borderRadius({
              topLeft: this.cartScale(8),
              topRight: this.cartScale(8)
            });
        } else {
          Row()
            .width('100%')
            .height(this.cartScale(120))
            .backgroundColor('#E8F0EC')
            .borderRadius({
              topLeft: this.cartScale(8),
              topRight: this.cartScale(8)
            });
        }
      }

      // Product info area
      Column() {
        Text(product.name || '茶品')
          .fontSize(this.cartScale(14))
          .fontWeight(FontWeight.Medium)
          .fontColor('#4D716F')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%');

        Row() {
          Text(product.priceText || '￥0')
            .fontSize(this.cartScale(14))
            .fontWeight(FontWeight.Bold)
            .fontColor('#D85E53');

          Blank();

          // Add to cart button (green circle with +)
          Row() {
            Text('+')
              .fontSize(this.cartScale(14))
              .fontColor(Color.White)
              .textAlign(TextAlign.Center);
          }
          .width(this.cartScale(22))
          .height(this.cartScale(22))
          .borderRadius(this.cartScale(11))
          .backgroundColor('#71AD91')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            // Add to cart
            const newItem = new CartItem(
              `rec_${Date.now()}`,
              product,
              1,
              true
            );
            const updated = [...this.cartItems, newItem];
            AppStorage.setOrCreate('cartItems', updated);
          });
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: this.cartScale(4) });
      }
      .width('100%')
      .padding({
        left: this.cartScale(8),
        right: this.cartScale(8),
        top: this.cartScale(8),
        bottom: this.cartScale(10)
      });
    }
    .width(this.cartScale(149))
    .backgroundColor(Color.White)
    .borderRadius(this.cartScale(8));
  }

  @Builder
  private RecommendSection() {
    Column() {
      // Title row: flourish + 为您推荐 + flourish
      Row() {
        // Left decorative flourish (mirrored)
        Image('data:image/png;base64,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')
          .width(this.cartScale(49))
          .height(this.cartScale(9))
          .objectFit(ImageFit.Contain)
          .rotate({ angle: 180 });

        Text('为您推荐')
          .fontSize(this.cartScale(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .margin({ left: this.cartScale(12), right: this.cartScale(12) });

        // Right decorative flourish
        Image('data:image/png;base64,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')
          .width(this.cartScale(49))
          .height(this.cartScale(9))
          .objectFit(ImageFit.Contain);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.cartScale(16) });

      // Divider line
      Row()
        .width(this.cartScale(312))
        .height(0.5)
        .backgroundColor('rgba(255,255,255,0.3)')
        .margin({ top: this.cartScale(14) });

      // Product grid - 2 columns
      Column() {
        // Row 1
        Row({ space: this.cartScale(12) }) {
          ForEach(this.getRecommendProducts().slice(0, 2), (product: FeaturedListCard) => {
            this.RecommendCard(product);
          });
        }

        // Row 2
        Row({ space: this.cartScale(12) }) {
          ForEach(this.getRecommendProducts().slice(2, 4), (product: FeaturedListCard) => {
            this.RecommendCard(product);
          });
        }
        .margin({ top: this.cartScale(12) });
      }
      .margin({ top: this.cartScale(16) })
      .padding({ bottom: this.cartScale(16) });
    }
    .width('100%')
    .backgroundColor('#71AD91')
    .borderRadius(this.cartScale(12))
    .padding({ left: this.cartScale(14), right: this.cartScale(14) })
    .margin({ top: this.cartScale(16) });
  }

  @Builder
  private PopulatedCartState() {
    Column() {
      List() {
        ForEach(this.cartItems, (item: CartItem, index: number) => {
          ListItem() {
            this.CartItemCard(item, index);
          }
        }, (item: CartItem, index: number) => item.id + index);

        // Recommend Section
        ListItem() {
          this.RecommendSection();
        }
        
        ListItem() {
          Row().height(this.cartScale(120)) // Padding for bottom bar
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: this.cartScale(16), right: this.cartScale(16) })
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private SettlementBar() {
    // Design spec: 292×48 capsule, #97C9C0 bg, #FFCD45 gold border
    Row() {
      // Checkbox (14×14 circle, white stroke)
      Row() {
        if (this.getAllSelected()) {
          Text('✓')
            .fontSize(this.cartScale(10))
            .fontColor('#97C9C0')
            .textAlign(TextAlign.Center);
        }
      }
      .width(this.cartScale(14))
      .height(this.cartScale(14))
      .borderRadius(this.cartScale(7))
      .backgroundColor(this.getAllSelected() ? Color.White : Color.Transparent)
      .border({ width: 1.5, color: Color.White })
      .justifyContent(FlexAlign.Center)
      .margin({ left: this.cartScale(14) })
      .onClick(() => {
        this.toggleAll(!this.getAllSelected());
      });

      // "全选" (white, 14px)
      Text('全选')
        .fontSize(this.cartScale(14))
        .fontColor(Color.White)
        .margin({ left: this.cartScale(4) });

      Blank();

      // Price area
      Column() {
        Text(`合计：￥${this.getTotalPrice().toFixed(0)}`)
          .fontSize(this.cartScale(14))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White);
        Text('含运费')
          .fontSize(this.cartScale(12))
          .fontColor(Color.White)
          .opacity(0.7)
          .margin({ top: this.cartScale(1) });
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ right: this.cartScale(10) });

      // "去结算" button (93×32, #4D716F, gold border, capsule)
      Button(`去结算（${this.getTotalSelectedCount()}）`)
        .width(this.cartScale(93))
        .height(this.cartScale(32))
        .backgroundColor('#4D716F')
        .fontColor(Color.White)
        .fontSize(this.cartScale(14))
        .borderRadius(this.cartScale(16))
        .border({ width: 1, color: '#FFCD45' })
        .margin({ right: this.cartScale(10) })
        .onClick(() => {
          this.currentRoute = AppRoute.CHECKOUT;
        });
    }
    .width(this.cartScale(292))
    .height(this.cartScale(48))
    .backgroundColor('#97C9C0')
    .borderRadius(this.cartScale(24))
    .border({ width: 1, color: '#FFCD45' })
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 98 + 20 });
  }

  build() {
    Column() {
      // Top Navigation Bar
      Row() {
        Text('我的购物车')
          .fontSize(this.cartScale(18))
          .fontWeight(FontWeight.Bold)
          .fontColor('#4D716F');
      }
      .width('100%')
      .height(this.cartScale(44) + 42)
      .padding({ top: 42 })
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Colors.cardBackground)
      .zIndex(10);

      // Main Content Area
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.cartItems.length === 0) {
          this.EmptyCartState();
        } else {
          this.PopulatedCartState();
          this.SettlementBar();
        }
      }
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
