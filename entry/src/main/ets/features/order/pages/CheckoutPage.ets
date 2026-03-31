import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { RouteParams } from '../../../router/RouteParams';
import { promptAction } from '@kit.ArkUI';
import { CartItem } from '../../cart/data/CartRepository';
import { CartRemoteRepository } from '../../cart/data/CartRemoteRepository';
import { CartStorage } from '../../cart/data/CartStorage';
import { HomeRepository } from '../../home/data/HomeRepository';
import { AddressRepository, Address } from '../data/AddressRepository';
import { OrderPreviewData, OrderPreviewItem, OrderRepository } from '../data/OrderRepository';

class AddressViewModel implements Address {
  id: string = '';
  recipient: string = '';
  phone: string = '';
  region: string = '';
  detail: string = '';
  isDefault: boolean = false;
}

class PriceParts {
  symbol: string = '';
  amount: string = '';
  unit: string = '';
}

class CheckoutDisplayItem {
  name: string = '';
  skuName: string = '';
  imageUrl: string = '';
  priceText: string = '';
  quantity: number = 1;
}

class CartItemSkuPair {
  item: CartItem;
  skuId: string = '';

  constructor(item: CartItem, skuId: string) {
    this.item = item;
    this.skuId = skuId;
  }
}


@Component
export struct CheckoutPage {
  @Link currentRoute: AppRoute;
  @StorageLink('cartItems') cartItems: CartItem[] = [];
  @State private homeContentWidth: number = 375;
  @State private orderNote: string = '';
  @State private hasAddress: boolean = false;
  @State private loadingAddress: boolean = false;
  @State private addressLoaded: boolean = false;
  @State private previewLoading: boolean = false;
  @State private usePreview: boolean = false;
  @State private previewData: OrderPreviewData = new OrderPreviewData();
  @State private submitting: boolean = false;
  @State private addresses: Address[] = [];
  @State private selectedAddress: AddressViewModel = new AddressViewModel();
  @State private focusSkuId: string = '';
  @State private focusQuantity: number = 1;
  @State private quantityDisplay: number = 1;
  @State private quantityDirty: boolean = false;

  private s(value: number): number {
    return value * this.homeContentWidth / 375;
  }

  aboutToAppear(): void {
    const params = NavService.getParams();
    if (params && params.skuId) {
      this.focusSkuId = params.skuId;
    }
    const selectedLocal = this.getSelectedItems();
    if (selectedLocal.length > 0) {
      this.focusQuantity = selectedLocal[0].quantity;
    } else if (this.cartItems.length > 0) {
      this.focusQuantity = this.cartItems[0].quantity;
    }
    this.quantityDisplay = this.focusQuantity;
    this.quantityDirty = false;
    void this.loadAddresses();
    void this.loadOrderPreview();
  }

  private async loadAddresses(): Promise<void> {
    if (this.loadingAddress) {
      return;
    }
    this.loadingAddress = true;
    this.addressLoaded = false;
    try {
      const list = await AddressRepository.getAddresses();
      this.addresses = list;
      if (list.length > 0) {
        this.hasAddress = true;
        const preferred = list.find(item => item.isDefault) || list[0];
        this.applySelectedAddress(preferred);
      } else {
        this.hasAddress = false;
        this.selectedAddress = new AddressViewModel();
      }
    } catch (error) {
      console.error('Failed to load addresses:', error);
      this.hasAddress = false;
      this.selectedAddress = new AddressViewModel();
    } finally {
      this.loadingAddress = false;
      this.addressLoaded = true;
    }
  }

  private applySelectedAddress(address: Address): void {
    const next = new AddressViewModel();
    next.id = address.id;
    next.recipient = address.recipient;
    next.phone = address.phone;
    next.region = address.region;
    next.detail = address.detail;
    next.isDefault = address.isDefault;
    this.selectedAddress = next;
  }

  private async loadOrderPreview(): Promise<void> {
    if (this.previewLoading) {
      return;
    }
    this.previewLoading = true;
    try {
      const cart = await CartRemoteRepository.getCart();
      let targetIds: string[] = [];
      if (this.focusSkuId.length > 0) {
        const match = cart.items.find(item => item.skuId === this.focusSkuId);
        if (match) {
          targetIds = [match.id];
          const needsQuantityUpdate = this.focusQuantity > 0 && match.quantity !== this.focusQuantity;
          const needsSelectUpdate = !match.selected;
          if (needsQuantityUpdate || needsSelectUpdate) {
            const nextQty = needsQuantityUpdate ? this.focusQuantity : match.quantity;
            await CartRemoteRepository.updateItem(match.id, nextQty, needsSelectUpdate ? true : undefined);
          }
        } else {
          this.previewData = new OrderPreviewData();
          this.usePreview = false;
          return;
        }
      } else {
        const selectedIds = cart.items.filter(item => item.selected).map(item => item.id);
        targetIds = selectedIds.length > 0 ? selectedIds : cart.items.map(item => item.id);
      }
      if (targetIds.length > 0) {
        const preview = await OrderRepository.preview(targetIds);
        this.previewData = preview;
        this.usePreview = preview.items.length > 0;
        if (this.usePreview) {
          if (this.quantityDirty) {
            this.updatePreviewQuantity(this.quantityDisplay);
          } else if (preview.items.length > 0) {
            this.quantityDisplay = preview.items[0].quantity;
          }
        }
      } else {
        this.previewData = new OrderPreviewData();
        this.usePreview = false;
      }
    } catch (error) {
      console.error('Failed to load order preview:', error);
      this.previewData = new OrderPreviewData();
      this.usePreview = false;
    } finally {
      this.previewLoading = false;
    }
  }

  private getDisplayItem(): CheckoutDisplayItem {
    const item = new CheckoutDisplayItem();
    if (this.usePreview && this.previewData.items.length > 0) {
      const previewItem = this.previewData.items[0];
      item.name = previewItem.productName;
      item.skuName = previewItem.skuName.length > 0 ? `规格：${previewItem.skuName}` : '';
      item.imageUrl = previewItem.imageUrl;
      item.quantity = previewItem.quantity;
      item.priceText = previewItem.priceCent > 0 ? `￥${(previewItem.priceCent / 100).toFixed(2)}` : previewItem.subtotalText;
      return item;
    }
    const selected = this.getSelectedItems();
    const localItem = selected.length > 0 ? selected[0] : (this.cartItems.length > 0 ? this.cartItems[0] : undefined);
    if (localItem) {
      item.name = localItem.product.name || '';
      item.skuName = localItem.product.subtitle ? `规格：${localItem.product.subtitle}` : '';
      item.imageUrl = localItem.product.imageUrl || '';
      item.quantity = localItem.quantity;
      item.priceText = localItem.product.priceText || '';
    }
    return item;
  }

  private updatePreviewQuantity(nextQty: number): void {
    const qty = nextQty < 1 ? 1 : nextQty;
    const next = new OrderPreviewData();
    next.discountCent = this.previewData.discountCent;
    next.shippingCent = this.previewData.shippingCent;
    next.addressRequired = this.previewData.addressRequired;
    let subtotal = 0;
    const items: OrderPreviewItem[] = [];
    for (let i = 0; i < this.previewData.items.length; i++) {
      const item = this.previewData.items[i];
      const updated = new OrderPreviewItem();
      updated.cartItemId = item.cartItemId;
      updated.skuId = item.skuId;
      updated.productName = item.productName;
      updated.skuName = item.skuName;
      updated.imageUrl = item.imageUrl;
      updated.quantity = i === 0 ? qty : item.quantity;
      updated.priceCent = item.priceCent;
      updated.subtotalCent = updated.priceCent * updated.quantity;
      updated.subtotalText = `￥${(updated.subtotalCent / 100).toFixed(2)}`;
      subtotal += updated.subtotalCent;
      items.push(updated);
    }
    next.items = items;
    next.subtotalCent = subtotal;
    next.payableCent = subtotal + next.shippingCent - next.discountCent;
    if (next.payableCent < 0) {
      next.payableCent = 0;
    }
    this.previewData = next;
    this.usePreview = true;
  }

  private updateLocalCartQuantity(nextQty: number): void {
    const qty = nextQty < 1 ? 1 : nextQty;
    const items = this.cartItems.slice();
    if (items.length === 0) {
      return;
    }
    let targetIndex = items.findIndex(item => item.selected);
    if (targetIndex < 0) {
      targetIndex = 0;
    }
    const updated: CartItem[] = [];
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (i === targetIndex) {
        updated.push(new CartItem(item.id, item.product, qty, item.selected));
      } else {
        updated.push(item);
      }
    }
    CartStorage.update(updated);
  }

  private updateLocalCartQuantityBySku(nextQty: number): void {
    const qty = nextQty < 1 ? 1 : nextQty;
    const skuId = this.focusSkuId.length > 0 ? this.focusSkuId : (this.previewData.items.length > 0 ? this.previewData.items[0].skuId : '');
    if (skuId.length === 0) {
      this.updateLocalCartQuantity(qty);
      return;
    }
    const items = this.cartItems.slice();
    const targetIndex = items.findIndex(item => item.product.skuId === skuId);
    if (targetIndex < 0) {
      this.updateLocalCartQuantity(qty);
      return;
    }
    const updated: CartItem[] = [];
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (i === targetIndex) {
        updated.push(new CartItem(item.id, item.product, qty, item.selected));
      } else {
        updated.push(item);
      }
    }
    CartStorage.update(updated);
  }

  private async syncRemoteQuantity(nextQty: number): Promise<void> {
    const qty = nextQty < 1 ? 1 : nextQty;
    let skuId: string = '';
    if (this.focusSkuId.length > 0) {
      skuId = this.focusSkuId;
    } else if (this.usePreview && this.previewData.items.length > 0) {
      skuId = this.previewData.items[0].skuId;
    } else {
      const selected = this.getSelectedItems();
      if (selected.length > 0) {
        skuId = selected[0].product.skuId || '';
      } else if (this.cartItems.length > 0) {
        skuId = this.cartItems[0].product.skuId || '';
      }
    }
    if (skuId.length === 0) {
      return;
    }
    const itemId = await CartStorage.ensureRemoteId(skuId);
    if (itemId.length === 0) {
      return;
    }
    await CartRemoteRepository.updateItem(itemId, qty, true);
  }

  private setDisplayQuantity(nextQty: number): void {
    const qty = nextQty < 1 ? 1 : nextQty;
    this.quantityDisplay = qty;
    this.quantityDirty = true;
    if (this.usePreview && this.previewData.items.length > 0) {
      this.updatePreviewQuantity(qty);
    }
    this.updateLocalCartQuantityBySku(qty);
    void this.syncRemoteQuantity(qty).catch((error: Error) => {
      console.error('Failed to sync remote quantity:', error);
    });
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

  private displayItemName(): string {
    return this.getDisplayItem().name;
  }

  private displayItemSkuName(): string {
    return this.getDisplayItem().skuName;
  }

  private displayItemImageUrl(): string {
    return this.getDisplayItem().imageUrl;
  }

  private displayItemQuantity(): number {
    if (this.quantityDisplay > 0) {
      return this.quantityDisplay;
    }
    if (this.usePreview && this.previewData.items.length > 0) {
      return this.previewData.items[0].quantity;
    }
    return this.getDisplayItem().quantity;
  }

  private displayItemPriceSymbol(): string {
    return this.parsePriceText(this.getDisplayItem().priceText).symbol;
  }

  private displayItemPriceAmount(): string {
    return this.parsePriceText(this.getDisplayItem().priceText).amount;
  }

  private async resolveSkuId(card: CartItem): Promise<string> {
    if (card.product.skuId && card.product.skuId.length > 0) {
      return card.product.skuId;
    }
    if (card.product.id && card.product.id.length > 0) {
      try {
        const detail = await HomeRepository.getProductDetail(card.product.id);
        if (detail.skus.length > 0) {
          return detail.skus[0].id;
        }
      } catch (error) {
        console.error('Failed to resolve skuId:', error);
      }
    }
    return '';
  }

  private getTargetCartItemIds(): string[] {
    if (this.usePreview && this.previewData.items.length > 0) {
      return this.previewData.items.map(item => item.cartItemId);
    }
    const selected = this.getSelectedItems();
    if (selected.length > 0) {
      return selected.map(item => item.id);
    }
    return this.cartItems.map(item => item.id);
  }

  private async submitOrder(): Promise<void> {
    if (this.submitting) {
      return;
    }
    if (!this.addressLoaded || !this.hasAddress || this.selectedAddress.id.length === 0) {
      this.currentRoute = AppRoute.ADDRESS;
      NavService.go(AppRoute.ADDRESS);
      return;
    }
    this.submitting = true;
    try {
      if (this.previewLoading) {
        await this.loadOrderPreview();
      }
      let cartItemIds: string[] = [];
      let needSelectAll: boolean = false;
      if (this.usePreview && this.previewData.items.length > 0) {
        cartItemIds = this.previewData.items.map(item => item.cartItemId);
      }
      if (cartItemIds.length === 0) {
        let cart = await CartRemoteRepository.getCart();
        if (cart.items.length === 0) {
          const selectedLocal = this.getSelectedItems();
          const fallbackLocal = selectedLocal.length > 0 ? selectedLocal : this.cartItems;
          if (fallbackLocal.length === 0) {
            promptAction.showToast({ message: '购物车为空' });
            return;
          }
          const resolved = await Promise.all(fallbackLocal.map(async (item) => {
            const skuId = await this.resolveSkuId(item);
            return new CartItemSkuPair(item, skuId);
          }));
          for (let i = 0; i < resolved.length; i++) {
            if (resolved[i].skuId.length === 0) {
              promptAction.showToast({ message: '缺少SKU，无法提交订单' });
              return;
            }
          }
          await Promise.all(resolved.map(res => CartRemoteRepository.addItem(res.skuId, res.item.quantity)));
          cart = await CartRemoteRepository.getCart();
        }
        const selectedIds = cart.items.filter(item => item.selected).map(item => item.id);
        cartItemIds = selectedIds.length > 0 ? selectedIds : cart.items.map(item => item.id);
        needSelectAll = selectedIds.length === 0;
      }
      if (cartItemIds.length === 0) {
        promptAction.showToast({ message: '未找到可提交的商品' });
        return;
      }
      if (needSelectAll) {
        await CartRemoteRepository.batchSelect(cartItemIds, true);
      }
      const result = await OrderRepository.createOrder(cartItemIds, this.selectedAddress.id);
      promptAction.showToast({ message: '订单提交成功' });
      
      // 清空本地购物车中已下单的商品
      const orderedIds = new Set(cartItemIds);
      const remainingItems = this.cartItems.filter(item => !orderedIds.has(item.id));
      CartStorage.update(remainingItems);
      
      // 同步远程购物车
      try {
        const remoteCart = await CartRemoteRepository.getCart();
        const remoteItems = remoteCart.items.map(item => {
          const localMatch = remainingItems.find(local => local.product.skuId === item.skuId);
          return new CartItem(item.id, localMatch?.product || {
            id: '',
            skuId: item.skuId,
            name: item.productName,
            subtitle: item.subtitle,
            imageUrl: item.imageUrl,
            priceText: item.priceText || item.subtotalText,
            badgePrimary: item.badges.length > 0 ? item.badges[0] : '',
            badgeSecondary: item.badges.length > 1 ? item.badges[1] : ''
          }, item.quantity, item.selected);
        });
        CartStorage.update(remoteItems);
      } catch (syncError) {
        console.error('Failed to sync cart after order:', syncError);
      }
      
      if (result.orderNo.length > 0) {
        const params = new RouteParams();
        params.orderNo = result.orderNo;
        params.totalCent = `${result.totalCent}`;
        params.paymentRequired = result.paymentRequired ? '1' : '0';
        NavService.go(AppRoute.PAYMENT_CONFIRM, params);
        this.currentRoute = AppRoute.PAYMENT_CONFIRM;
      }
    } catch (error) {
      console.error('Failed to submit order:', error);
      promptAction.showToast({ message: '提交订单失败' });
    } finally {
      this.submitting = false;
    }
  }
  private getSelectedItems(): CartItem[] {
    return this.cartItems.filter(item => item.selected);
  }

  private getTotalPrice(): number {
    if (this.usePreview) {
      return this.previewData.subtotalCent / 100;
    }
    return this.getSelectedItems().reduce((sum: number, item: CartItem) => {
      const priceStr = item.product.priceText || '0';
      const match = priceStr.match(/\d+(\.\d+)?/);
      const priceVal = match ? parseFloat(match[0]) : 0;
      return sum + (priceVal * item.quantity);
    }, 0);
  }

  private getTotalCount(): number {
    if (this.usePreview) {
      return this.previewData.items.reduce((sum: number, item) => sum + item.quantity, 0);
    }
    return this.getSelectedItems().reduce((sum: number, item: CartItem) => sum + item.quantity, 0);
  }

  private getDiscountAmount(): number {
    if (this.usePreview) {
      return this.previewData.discountCent / 100;
    }
    return 0;
  }

  private getShippingAmount(): number {
    if (this.usePreview) {
      return this.previewData.shippingCent / 100;
    }
    return 0;
  }

  private getFinalPrice(): number {
    if (this.usePreview) {
      return this.previewData.payableCent / 100;
    }
    const total = this.getTotalPrice();
    const discount = this.getDiscountAmount();
    const final = total - discount;
    return final > 0 ? final : 0.2;
  }

  @Builder
  private TitleBar() {
    Row() {
      // Back button
      Row() {
        Image($rawfile('ic_checkout_back.svg'))
          .width(this.s(14))
          .height(this.s(14))
          .objectFit(ImageFit.Contain);
      }
      .width(this.s(22))
      .height(this.s(22))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.currentRoute = AppRoute.CART;
      });

      Blank();

      Text('确认订单')
        .fontSize(this.s(20))
        .fontWeight(FontWeight.Medium)
        .fontColor('#4D716F');

      Blank();

      // Invisible spacer to balance layout
      Row().width(this.s(22)).height(this.s(22));
    }
    .width('100%')
    .height(this.s(30) + 42)
    .padding({ top: 42, left: this.s(20), right: this.s(20) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#F2F7F0');
  }

  @Builder
  private NoAddressSection() {
    Column() {
      // Illustration image exported from design
      Image($r('app.media.checkout_no_address_illustration'))
        .width(this.s(300))
        .height(this.s(160))
        .objectFit(ImageFit.Contain)
        .margin({ top: this.s(16) });

      // Main text
      Text('前往雪餐厅的路被真寻酱拦截啦~')
        .fontSize(this.s(14))
        .fontColor('#4D716F')
        .fontWeight(FontWeight.Medium)
        .margin({ top: this.s(16) });

      // Subtitle
      Text('您当前还未添加地址，添加地址后方可发货')
        .fontSize(this.s(12))
        .fontColor('#4D716F')
        .opacity(0.7)
        .margin({ top: this.s(8) });

      // Add address button (90×28, capsule border, no fill)
      Button('新增地址', { type: ButtonType.Normal })
        .width(this.s(100))
        .height(this.s(28))
        .fontSize(this.s(16))
        .fontColor('#4D716F')
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: '#4D716F' })
        .borderRadius(this.s(101))
        .margin({ top: this.s(16) })
        .onClick(() => {
          this.currentRoute = AppRoute.ADDRESS;
          NavService.go(AppRoute.ADDRESS);
        });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: this.s(24) });
  }

  @Builder
  private AddressSection() {
    Row() {
      // Location icon circle
      Stack() {
        Row()
          .width(this.s(28))
          .height(this.s(28))
          .borderRadius(this.s(14))
          .backgroundColor('#4D716F');
        // Location pin icon path (white)
        Image($rawfile('ic_checkout_location.svg'))
          .width(this.s(12))
          .height(this.s(15))
          .objectFit(ImageFit.Contain);
      }

      Column() {
        Text(`${this.selectedAddress.recipient}  ${this.selectedAddress.phone}`)
          .fontSize(this.s(14))
          .fontColor('#4D716F')
          .fontWeight(FontWeight.Medium);
        Text(`${this.selectedAddress.region} ${this.selectedAddress.detail}`)
          .fontSize(this.s(14))
          .fontColor('#4D716F')
          .margin({ top: this.s(4) });
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.s(12) });

      Blank();

      // Settings/scan icon
      Image($rawfile('ic_checkout_scan.svg'))
        .width(this.s(28))
        .height(this.s(28))
        .objectFit(ImageFit.Contain);
    }
    .width('100%')
    .padding({ left: this.s(21), right: this.s(9), top: this.s(6), bottom: this.s(10) })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.currentRoute = AppRoute.ADDRESS;
      NavService.go(AppRoute.ADDRESS);
    });
  }

  @Builder
  private LoadingAddressSection() {
    Row()
      .width('100%')
      .height(this.s(60))
      .padding({ left: this.s(21), right: this.s(9), top: this.s(6), bottom: this.s(10) })
      .backgroundColor(Color.Transparent);
  }

  @Builder
  private ShopProductCard() {
    Column() {
      // Use pattern background image similar to CartPage
      Column() {
        // Shop header row
        Row() {
          // Shop icon
          Image($rawfile('ic_checkout_shop.svg'))
            .width(this.s(18))
            .height(this.s(18))
            .objectFit(ImageFit.Contain);

          Text('梅州会员制餐厅专卖店')
            .fontSize(this.s(16))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .margin({ left: this.s(4) });

          Blank();

          // Arrow right
          Text('>')
            .fontSize(this.s(16))
            .fontColor(Color.White);
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);

        // Product row
        Row({ space: this.s(16) }) {
          // Product image
          if (this.displayItemImageUrl().length > 0) {
            Image(this.displayItemImageUrl())
              .width(this.s(76))
              .height(this.s(73))
              .borderRadius(this.s(6))
              .objectFit(ImageFit.Cover);
          } else {
            Row()
              .width(this.s(76))
              .height(this.s(73))
              .borderRadius(this.s(6))
              .backgroundColor('rgba(255,255,255,0.3)');
          }

          Column() {
            Text(this.displayItemName())
              .fontSize(this.s(16))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

            Text(this.displayItemSkuName())
              .fontSize(this.s(10))
              .fontColor(Color.White)
              .opacity(0.7)
              .margin({ top: this.s(2) });

            Blank();

            Row() {
              Text(this.displayItemPriceSymbol())
                .fontSize(this.s(12))
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold);
              Text(this.displayItemPriceAmount())
                .fontSize(this.s(20))
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold);

              Blank();

              // Quantity controls
              Row() {
                Text('—')
                  .width(this.s(20))
                  .height(this.s(17))
                  .textAlign(TextAlign.Center)
                  .fontSize(this.s(14))
                  .fontColor(Color.White)
                  .border({ width: 1, color: Color.White, radius: this.s(8) })
                  .onClick(() => {
                    this.setDisplayQuantity(this.quantityDisplay - 1);
                  });
                Text(`${this.quantityDisplay}`)
                  .width(this.s(24))
                  .textAlign(TextAlign.Center)
                  .fontSize(this.s(14))
                  .fontColor(Color.White)
                  .key(`${this.quantityDisplay}`);
                Text('+')
                  .width(this.s(20))
                  .height(this.s(17))
                  .textAlign(TextAlign.Center)
                  .fontSize(this.s(14))
                  .fontColor(Color.White)
                  .border({ width: 1, color: Color.White, radius: this.s(8) })
                  .onClick(() => {
                    this.setDisplayQuantity(this.quantityDisplay + 1);
                  });
              }
            }
            .width('100%')
            .alignItems(VerticalAlign.Bottom);
          }
          .layoutWeight(1)
          .height(this.s(73))
          .alignItems(HorizontalAlign.Start);
        }
        .margin({ top: this.s(12) });

        // Dashed divider
        Text('- - - - - - - - - - - - - - - - - - - - - - - - - - - -')
          .fontSize(this.s(10))
          .fontColor(Color.White)
          .opacity(0.5)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: this.s(16) })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip });

        // Delivery method
        Row() {
          Text('配送方式')
            .fontSize(this.s(14))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium);
          Blank();
          Column() {
            Text('快递  包邮')
              .fontSize(this.s(14))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium);
            Text('节假日/双休日放假，不服憋着')
              .fontSize(this.s(10))
              .fontColor(Color.White)
              .opacity(0.7)
              .margin({ top: this.s(2) });
          }
          .alignItems(HorizontalAlign.End);
        }
        .width('100%')
        .margin({ top: this.s(12) })
        .alignItems(VerticalAlign.Top);

        // Order note
        Row() {
          Text('订单备注：')
            .fontSize(this.s(14))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium);

          Column() {
            TextArea({ placeholder: '和商家协商一致后留言，最多114514字', text: this.orderNote })
              .fontSize(this.s(10))
              .fontColor(Color.White)
              .placeholderColor('rgba(255,255,255,0.8)')
              .placeholderFont({ size: this.s(10) })
              .backgroundColor(Color.Transparent)
              .height(this.s(38))
              .width('100%')
              .padding({ top: this.s(4), left: 0, right: 0, bottom: 0 })
              .onChange((value: string) => {
                this.orderNote = value;
              });
          }
          .layoutWeight(1)
          .height(this.s(38))
          .backgroundColor('rgba(242,247,240,0.3)')
          .borderRadius(this.s(4))
          .padding({ left: this.s(12), right: this.s(12) })
          .margin({ left: this.s(4) });
        }
        .width('100%')
        .margin({ top: this.s(16) })
        .alignItems(VerticalAlign.Top);
      }
      .width('100%')
      .padding(this.s(16))
      .backgroundColor('#71AD91')
      .backgroundImage($r('app.media.home_new_tea_card_pattern'), ImageRepeat.NoRepeat)
      .backgroundImageSize({ width: '100%' })
      .backgroundImagePosition(Alignment.Bottom)
      .borderRadius(this.s(10));
    }
    .width('100%')
    .padding({ left: this.s(21), right: this.s(15) });
  }

  @Builder
  private PriceSummaryCard() {
    Column() {
      // Product amount
      Row() {
        Text('商品金额')
          .fontSize(this.s(14))
          .fontColor('#4D716F')
          .fontWeight(FontWeight.Medium);
        Blank();
        Text(`￥${this.getTotalPrice().toFixed(2)}`)
          .fontSize(this.s(14))
          .fontColor('#4D716F')
          .fontWeight(FontWeight.Medium);
      }
      .width('100%');

      // Dashed divider
      Text('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -')
        .fontSize(this.s(10))
        .fontColor('#4D716F')
        .opacity(0.2)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: this.s(14), bottom: this.s(14) })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip });

      // Coupon
      Row() {
        Text('优惠券')
          .fontSize(this.s(14))
          .fontColor('#4D716F');
        Blank();
        Text('（已使用优惠券）')
          .fontSize(this.s(12))
          .fontColor('#4D716F')
          .opacity(0.7);
        Text(`-${this.getDiscountAmount().toFixed(2)}`)
          .fontSize(this.s(14))
          .fontColor('#71AD91')
          .fontWeight(FontWeight.Bold);
        // Arrow right
        Text('>')
          .fontSize(this.s(14))
          .fontColor('#71AD91')
          .margin({ left: this.s(4) });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      // Dashed divider
      Text('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -')
        .fontSize(this.s(10))
        .fontColor('#4D716F')
        .opacity(0.2)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: this.s(14), bottom: this.s(14) })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip });

      // Invoice
      Row() {
        Text('发票')
          .fontSize(this.s(14))
          .fontColor('#4D716F');
        Blank();
        Text('不开发票')
          .fontSize(this.s(14))
          .fontColor('#4D716F')
          .opacity(0.7);
        Text('>')
          .fontSize(this.s(14))
          .fontColor('#4D716F')
          .opacity(0.5)
          .margin({ left: this.s(4) });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .padding({
      left: this.s(12),
      right: this.s(8),
      top: this.s(15),
      bottom: this.s(15)
    })
    .backgroundColor(Color.White)
    .borderRadius(this.s(8))
    .shadow({ radius: 8, color: 'rgba(77,113,111,0.24)', offsetX: 0, offsetY: 4 });
  }

  @Builder
  private RecommendSection() {
    Column() {
      // Title row with decorative flourishes
      Row() {
        // Left flourish (mirrored)
        Image('data:image/png;base64,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')
          .width(this.s(49))
          .height(this.s(9))
          .objectFit(ImageFit.Contain)
          .rotate({ angle: 180 });

        Text('为您推荐')
          .fontSize(this.s(16))
          .fontWeight(FontWeight.Medium)
          .fontColor('#4D716F')
          .margin({ left: this.s(12), right: this.s(12) });

        // Right flourish
        Image('data:image/png;base64,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')
          .width(this.s(49))
          .height(this.s(9))
          .objectFit(ImageFit.Contain);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.s(16) });

      // Divider
      Row()
        .width(this.s(312))
        .height(0.5)
        .backgroundColor('rgba(77,113,111,0.15)')
        .margin({ top: this.s(14) });

      // Recommendation items row
      Row({ space: this.s(12) }) {
        this.RecommendItemCard('客家红茶 小专区', '￥181/盒');
        this.RecommendItemCard('客家乌龙茶', '￥114/盒');
      }
      .margin({ top: this.s(16), bottom: this.s(16) })
      .justifyContent(FlexAlign.Center);
    }
    .width('100%')
    .margin({ left: this.s(20), right: this.s(15), top: this.s(24) })
    .backgroundColor(Color.White)
    .borderRadius(this.s(10))
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 1 })
    .padding({ left: this.s(15), right: this.s(15) });
  }

  @Builder
  private RecommendItemCard(name: string, price: string) {
    Column() {
      // Image placeholder
      Row()
        .width(this.s(149))
        .height(this.s(120))
        .backgroundColor('#E8F0EC')
        .borderRadius({
          topLeft: this.s(8),
          topRight: this.s(8)
        });

      Column() {
        Text(name)
          .fontSize(this.s(14))
          .fontWeight(FontWeight.Medium)
          .fontColor('#4D716F')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%');

        Row() {
          Text(price)
            .fontSize(this.s(14))
            .fontWeight(FontWeight.Bold)
            .fontColor('#D85E53');

          Blank();

          // Add to cart circle button
          Row() {
            Text('+')
              .fontSize(this.s(14))
              .fontColor(Color.White)
              .textAlign(TextAlign.Center);
          }
          .width(this.s(22))
          .height(this.s(22))
          .borderRadius(this.s(11))
          .backgroundColor('#71AD91')
          .justifyContent(FlexAlign.Center);
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: this.s(4) });
      }
      .width('100%')
      .padding({
        left: this.s(8),
        right: this.s(8),
        top: this.s(8),
        bottom: this.s(10)
      });
    }
    .width(this.s(149))
    .backgroundColor('#F8FBF8')
    .borderRadius(this.s(8));
  }

  @Builder
  private BottomBar() {
    Column() {
      Row() {
        // Item count
        Text(`共${this.getTotalCount()}件`)
          .fontSize(this.s(12))
          .fontColor('#666666');

        // Price summary
        Column() {
          Row() {
            Text('合计：')
              .fontSize(this.s(14))
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold);
            Text(`￥${this.getFinalPrice().toFixed(2)}`)
              .fontSize(this.s(14))
              .fontColor('#D85E53')
              .fontWeight(FontWeight.Bold);
            Text(`（已优惠${this.getDiscountAmount().toFixed(2)}）`)
              .fontSize(this.s(12))
              .fontColor('#666666');
          }
          .alignItems(VerticalAlign.Bottom);

          Text(this.getShippingAmount() > 0 ? `含运费￥${this.getShippingAmount().toFixed(2)}` : '含运费')
            .fontSize(this.s(12))
            .fontColor('#666666')
            .margin({ top: this.s(2) });
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: this.s(8) });

        Blank();

        // Submit order button — use exported image for textured gradient quality
        Stack() {
          Image($r('app.media.checkout_submit_btn'))
            .width(this.s(98))
            .height(this.s(38))
            .borderRadius(this.s(4))
            .objectFit(ImageFit.Fill)
            .opacity(this.submitting ? 0.55 : 1);
          Text(this.submitting ? '提交中...' : '提交订单')
            .fontSize(this.s(16))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .opacity(this.submitting ? 0.7 : 1);
        }
        .width(this.s(98))
        .height(this.s(38))
        .onClick(() => {
          if (this.submitting) {
            return;
          }
          this.submitOrder();
        });
      }
      .width('100%')
      .padding({
        left: this.s(16),
        right: this.s(16),
        top: this.s(10),
        bottom: this.s(10)
      })
      .alignItems(VerticalAlign.Center);

      // Home indicator bar
      Row()
        .width(this.s(119))
        .height(this.s(4))
        .borderRadius(this.s(185))
        .backgroundColor('rgba(196,196,196,0.8)')
        .margin({ top: this.s(8), bottom: this.s(8) });
    }
    .width('100%')
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Center)
    .borderRadius({ topLeft: this.s(16), topRight: this.s(16) })
    .shadow({ radius: 6, color: 'rgba(127,176,173,0.3)', offsetX: 0, offsetY: -2 });
  }

  build() {
    Column() {
      // Title bar
      this.TitleBar();

      // Scrollable content
      Scroll() {
        Column() {
          // Address section or No Address section
          if (!this.addressLoaded || this.loadingAddress) {
            this.LoadingAddressSection();
          } else if (this.hasAddress) {
            this.AddressSection();
          } else {
            this.NoAddressSection();
          }

          // Shop & product card
          this.ShopProductCard();

          // Price summary (wrapped in same padding as ShopProductCard)
          Column() {
            this.PriceSummaryCard();
          }
          .width('100%')
          .padding({ left: this.s(21), right: this.s(15) })
          .margin({ top: this.s(24) });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      // Bottom fixed bar
      this.BottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F7F0')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onAreaChange((oldValue, newValue) => {
      void oldValue;
      const width = Number(newValue.width);
      if (width > 0) {
        this.homeContentWidth = width;
      }
    });
  }
}
