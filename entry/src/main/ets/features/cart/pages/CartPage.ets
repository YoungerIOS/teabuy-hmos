import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { RouteParams } from '../../../router/RouteParams';
import { Colors } from '../../../core/ui/theme/Tokens';
import { CartItem } from '../data/CartRepository';
import { CartRemoteRepository } from '../data/CartRemoteRepository';
import { CartStorage } from '../data/CartStorage';
import { FeaturedListCard } from '../../home/data/HomeRepository';

@Component
export struct CartPage {
  @Link currentRoute: AppRoute;
  @Link activeNav: number;
  @StorageLink('cartItems') cartItems: CartItem[] = [];

  // TODO: we should pull actual content width or just define it.
  @State private homeContentWidth: number = 375;
  @State private activeDeletePopupIndex: number = -1;
  @State private cartRevision: number = 0;
  @State private isSelectMode: boolean = false; // 多选模式
  @StorageLink('cartRecommendations') recommendProducts: FeaturedListCard[] = [];

  private cartScale(value: number): number {
    return value * this.homeContentWidth / 375;
  }

  aboutToAppear(): void {
    // 页面显示时,取消所有商品的选中状态
    this.clearAllSelections();
    void CartStorage.refreshRecommendations(getContext(this));
  }

  private clearAllSelections(): void {
    const updated = this.cartItems.map(item => new CartItem(item.id, item.product, item.quantity, false));
    this.cartItems = updated;
    this.cartRevision += 1;
    CartStorage.update(updated);
  }

  private getRecommendProducts(): FeaturedListCard[] {
    return this.recommendProducts;
  }

  @Builder
  private DeletePopup(index: number) {
    Column() {
      Row() {
        Text('去结算')
          .fontSize(this.cartScale(12))
          .fontColor('#4D716F')
          .textAlign(TextAlign.Center)
          .width('100%');
      }
      .width('100%')
      .height(this.cartScale(32))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.checkoutSingle(index);
        this.activeDeletePopupIndex = -1;
      });

      Row()
        .width('100%')
        .height(0.5)
        .backgroundColor('#E8E8E8');

      Row() {
        Text('删除')
          .fontSize(this.cartScale(12))
          .fontColor('#FF4D4F')
          .textAlign(TextAlign.Center)
          .width('100%');
      }
      .width('100%')
      .height(this.cartScale(32))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.removeItem(index);
        this.activeDeletePopupIndex = -1;
      });
    }
    .width(this.cartScale(74))
    .backgroundColor(Color.White)
    .borderRadius(this.cartScale(6))
    .border({ width: 1, color: '#E8E8E8' })
    .clip(true);
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
            this.activeNav = 0;
            this.currentRoute = AppRoute.HOME;
            NavService.go(AppRoute.HOME);
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

  private syncRemoteUpdate(item: CartItem): void {
    const skuId = item.product.skuId || '';
    if (skuId.length === 0) {
      return;
    }
    void CartStorage.ensureRemoteId(skuId).then((itemId: string) => {
      if (itemId.length === 0) {
        return;
      }
      void CartRemoteRepository.updateItem(itemId, item.quantity, item.selected).catch((error: Error) => {
        console.error('Failed to update remote cart item:', error);
      });
    });
  }

  private syncRemoteDelete(item: CartItem): void {
    const skuId = item.product.skuId || '';
    if (skuId.length === 0) {
      return;
    }
    void CartStorage.ensureRemoteId(skuId).then((itemId: string) => {
      if (itemId.length === 0) {
        return;
      }
      void CartRemoteRepository.deleteItem(itemId).catch((error: Error) => {
        console.error('Failed to delete remote cart item:', error);
      });
    });
  }

  private toggleAll(selected: boolean) {
    const updated = this.cartItems.map(item => new CartItem(item.id, item.product, item.quantity, selected));
    this.cartItems = updated;
    this.cartRevision += 1;
    CartStorage.update(updated);
    const ids = this.cartItems
      .map(item => CartStorage.getRemoteIdBySku(item.product.skuId || ''))
      .filter(id => id.length > 0);
    if (ids.length > 0) {
      void CartRemoteRepository.batchSelect(ids, selected).catch((error: Error) => {
        console.error('Failed to sync remote selection:', error);
      });
    }
  }

  private updateItemCount(index: number, delta: number) {
    const updated = [...this.cartItems];
    const current = updated[index];
    const newQty = current.quantity + delta;
    if (newQty <= 0) {
      const removed = updated.splice(index, 1);
      if (removed.length > 0) {
        this.syncRemoteDelete(removed[0]);
      }
    } else {
      const nextItem = new CartItem(current.id, current.product, newQty, current.selected);
      updated[index] = nextItem;
      this.syncRemoteUpdate(nextItem);
    }
    this.cartItems = updated;
    this.cartRevision += 1;
    CartStorage.update(updated);
  }

  private toggleItemSelection(index: number) {
    const updated = [...this.cartItems];
    const current = updated[index];
    const nextItem = new CartItem(current.id, current.product, current.quantity, !current.selected);
    updated[index] = nextItem;
    this.cartItems = updated;
    this.cartRevision += 1;
    CartStorage.update(updated);
    this.syncRemoteUpdate(nextItem);
  }

  private removeItem(index: number) {
    const updated = [...this.cartItems];
    const removed = updated.splice(index, 1);
    this.cartItems = updated;
    this.cartRevision += 1;
    CartStorage.update(updated);
    if (removed.length > 0) {
      this.syncRemoteDelete(removed[0]);
    }
  }

  private checkoutSingle(index: number): void {
    if (index < 0 || index >= this.cartItems.length) {
      return;
    }
    const updated: CartItem[] = [];
    for (let i = 0; i < this.cartItems.length; i++) {
      const item = this.cartItems[i];
      updated.push(new CartItem(item.id, item.product, item.quantity, i === index));
    }
    this.cartItems = updated;
    this.cartRevision += 1;
    CartStorage.update(updated);

    const target = updated[index];
    const params = new RouteParams();
    if (target.product.id && target.product.id.length > 0) {
      params.productId = target.product.id;
    }
    if (target.product.skuId && target.product.skuId.length > 0) {
      params.skuId = target.product.skuId;
    }
    this.currentRoute = AppRoute.CHECKOUT;
    NavService.go(AppRoute.CHECKOUT, params);
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
                  mask: false,
                  radius: this.cartScale(6),
                  shadow: {
                    radius: 0,
                    color: 'transparent',
                    offsetX: 0,
                    offsetY: 0
                  },
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
                  .fontColor(Colors.cardBackground)
                  .key(`${item.id}_${item.quantity}_${this.cartRevision}`);

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
        
        // 多选模式下显示选择框(覆盖在卡片内部右侧)
        if (this.isSelectMode) {
          Column() {
            Row() {
              if (item.selected) {
                // 选中状态
                Row()
                  .width(this.cartScale(24))
                  .height(this.cartScale(24))
                  .borderRadius(this.cartScale(12))
                  .backgroundColor('#4D716F')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center);
              } else {
                // 未选中状态
                Row()
                  .width(this.cartScale(24))
                  .height(this.cartScale(24))
                  .borderRadius(this.cartScale(12))
                  .border({ width: 2, color: '#4D716F' })
                  .backgroundColor(Color.White);
              }
            }
            .onClick(() => {
              this.toggleItemSelection(index);
            });
          }
          .width(this.cartScale(40))
          .height(this.cartScale(103))
          .justifyContent(FlexAlign.Center)
          .position({ x: '100%', y: this.cartScale(12) })
          .translate({ x: -this.cartScale(52), y: 0 });
        }
      }
      .layoutWeight(1);
    }
    .width('100%')
    .margin({ top: this.cartScale(12), bottom: this.cartScale(12) });
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
            CartStorage.update(updated);
            if (product.skuId && product.skuId.length > 0) {
              void CartRemoteRepository.addItem(product.skuId, 1).catch((error: Error) => {
                console.error('Failed to add cart item remotely:', error);
              });
            }
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
    if (this.getRecommendProducts().length > 0) {
      Column() {
      // Title row: flourish + 为您推荐 + flourish
      Row() {
        // Left decorative flourish (mirrored)
        Image($r('app.media.promo_decoration_left'))
          .width(this.cartScale(49))
          .height(this.cartScale(9))
          .objectFit(ImageFit.Contain)
          .margin({ right: this.cartScale(20) });

        Text('为您推荐')
          .fontSize(this.cartScale(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .margin({ left: 0, right: 0 });

        // Right decorative flourish
        Image($r('app.media.promo_decoration_right'))
          .width(this.cartScale(49))
          .height(this.cartScale(9))
          .objectFit(ImageFit.Contain)
          .margin({ left: this.cartScale(20) });
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
  }

  @Builder
  private PopulatedCartState() {
    Column() {
      List() {
        ForEach(this.cartItems, (item: CartItem, index: number) => {
          ListItem() {
            this.CartItemCard(item, index);
          }
          .key(`${item.id}_${item.quantity}_${item.selected}_${this.cartRevision}`);
        }, (item: CartItem, index: number) => `${item.id}_${item.quantity}_${item.selected}_${this.cartRevision}_${index}`);

        // Recommend Section
        ListItem() {
          this.RecommendSection();
        }
        
        ListItem() {
          Row().height(this.cartScale(160)) // Extra padding so Recommend section clears settlement bar
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
        // 左侧占位,保持标题居中
        if (this.cartItems.length > 0) {
          Text(this.isSelectMode ? '取消' : '选择')
            .fontSize(this.cartScale(14))
            .fontColor(Color.Transparent)
            .width(this.cartScale(50))
            .margin({ left: this.cartScale(16) });
        } else {
          Row()
            .width(this.cartScale(50))
            .margin({ left: this.cartScale(16) });
        }
        
        Text('我的购物车')
          .fontSize(this.cartScale(18))
          .fontWeight(FontWeight.Bold)
          .fontColor('#4D716F')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
        
        // 选择按钮
        if (this.cartItems.length > 0) {
          Text(this.isSelectMode ? '取消' : '选择')
            .fontSize(this.cartScale(14))
            .fontColor('#4D716F')
            .width(this.cartScale(50))
            .margin({ right: this.cartScale(16) })
            .onClick(() => {
              this.isSelectMode = !this.isSelectMode;
              if (!this.isSelectMode) {
                // 退出选择模式时,取消所有选中
                this.clearAllSelections();
              }
            });
        } else {
          Row()
            .width(this.cartScale(50))
            .margin({ right: this.cartScale(16) });
        }
      }
      .width('100%')
      .height(this.cartScale(44) + 42)
      .padding({ top: 42 })
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
