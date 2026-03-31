import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { RouteParams } from '../../../router/RouteParams';
import { promptAction, window } from '@kit.ArkUI';
import { Colors } from '../../../core/ui/theme/Tokens';
import { OrderDetailData, OrderRepository } from '../data/OrderRepository';
import { PaymentRepository } from '../data/PaymentRepository';

class PriceParts {
  symbol: string = '';
  amount: string = '';
  unit: string = '';
}


@Component
export struct PaymentConfirmPage {
  @Link currentRoute: AppRoute;
  @State private pageWidth: number = 375;
  @State private orderNo: string = '';
  @State private totalCent: number = 0;
  @State private paymentRequired: boolean = true;
  @State private status: string = 'PENDING_PAYMENT';
  @State private paying: boolean = false;
  @State private loading: boolean = false;
  @State private topSafeAreaPx: number = 0;

  private s(value: number): number {
    return value * this.pageWidth / 375;
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topSafeAreaPx = px2vp(avoidArea.topRect.height);
    }).catch(() => {
      this.topSafeAreaPx = 44;
    });
    const params = NavService.getParams();
    if (params && params.orderNo) {
      this.orderNo = params.orderNo;
    }
    if (params && params.totalCent) {
      const parsed = parseInt(params.totalCent, 10);
      this.totalCent = Number.isFinite(parsed) ? parsed : 0;
    }
    if (params && params.paymentRequired) {
      this.paymentRequired = params.paymentRequired === '1' || params.paymentRequired === 'true';
    }
    if (this.orderNo.length > 0) {
      this.loadOrderDetail();
    }
  }

  private async loadOrderDetail(): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const detail: OrderDetailData = await OrderRepository.getDetail(this.orderNo);
      if (detail.orderNo.length > 0) {
        this.status = detail.status;
        this.totalCent = detail.totalCent > 0 ? detail.totalCent : this.totalCent;
        this.paymentRequired = detail.canPay || detail.status === 'PENDING_PAYMENT';
      }
    } catch (error) {
      console.error('Failed to load order detail:', error);
    } finally {
      this.loading = false;
    }
  }

  private priceParts(valueCent: number): PriceParts {
    const parts = new PriceParts();
    const amount = valueCent / 100;
    parts.symbol = '￥';
    parts.amount = amount.toFixed(2);
    parts.unit = '';
    return parts;
  }

  private totalPriceSymbol(): string {
    return this.priceParts(this.totalCent).symbol;
  }

  private totalPriceAmount(): string {
    return this.priceParts(this.totalCent).amount;
  }

  private statusLabel(): string {
    if (this.status === 'PAID') {
      return '已支付';
    }
    if (this.status === 'SHIPPED') {
      return '待收货';
    }
    if (this.status === 'COMPLETED') {
      return '已完成';
    }
    return '待支付';
  }

  private async onPay(): Promise<void> {
    if (this.paying || this.orderNo.length === 0) {
      return;
    }
    this.paying = true;
    try {
      await PaymentRepository.mockPay(this.orderNo, true);
      let nextTotal = this.totalCent;
      try {
        const detail = await OrderRepository.getDetail(this.orderNo);
        this.status = detail.status;
        nextTotal = detail.totalCent > 0 ? detail.totalCent : this.totalCent;
      } catch (error) {
        console.error('Failed to refresh order status:', error);
      }
      this.totalCent = nextTotal;
      const params = new RouteParams();
      params.orderNo = this.orderNo;
      params.totalCent = `${nextTotal}`;
      NavService.go(AppRoute.PAYMENT_SUCCESS, params);
      this.currentRoute = AppRoute.PAYMENT_SUCCESS;
    } catch (error) {
      console.error('Payment failed:', error);
      promptAction.showToast({ message: '支付失败，请重试' });
    } finally {
      this.paying = false;
    }
  }

  @Builder
  private TitleBar() {
    Row() {
      Row() {
        Image($rawfile('ic_checkout_back.svg'))
          .width(this.s(14))
          .height(this.s(14))
          .objectFit(ImageFit.Contain);
      }
      .width(this.s(36))
      .height(this.s(36))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        NavService.back();
        this.currentRoute = NavService.getCurrentRoute();
      });

      Text('支付确认')
        .fontSize(this.s(18))
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.textPrimary)
        .margin({ left: this.s(4) });

      Blank();
    }
    .width('100%')
    .height(this.s(52))
    .padding({ left: this.s(16), right: this.s(16) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private OrderSummaryCard() {
    Column() {
      Row() {
        Text('订单号')
          .fontSize(this.s(12))
          .fontColor(Colors.textSecondary);
        Blank();
        Text(this.orderNo)
          .fontSize(this.s(12))
          .fontColor(Colors.textPrimary);
      }
      .width('100%');

      Row() {
        Text('订单状态')
          .fontSize(this.s(12))
          .fontColor(Colors.textSecondary);
        Blank();
        Text(this.statusLabel())
          .fontSize(this.s(12))
          .fontColor(Colors.textPrimary);
      }
      .width('100%')
      .margin({ top: this.s(10) });

      Row() {
        Text('应付金额')
          .fontSize(this.s(12))
          .fontColor(Colors.textSecondary);
        Blank();
        Row() {
          Text(this.totalPriceSymbol())
            .fontSize(this.s(12))
            .fontColor(Colors.brandPrimary)
            .fontWeight(FontWeight.Medium);
          Text(this.totalPriceAmount())
            .fontSize(this.s(18))
            .fontColor(Colors.brandPrimary)
            .fontWeight(FontWeight.Bold);
        }
      }
      .width('100%')
      .margin({ top: this.s(10) });
    }
    .width('100%')
    .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
    .backgroundColor(Colors.cardBackground)
    .borderRadius(this.s(12));
  }

  @Builder
  private ActionArea() {
    Column() {
      if (this.paymentRequired && this.status === 'PENDING_PAYMENT') {
        Button(this.paying ? '支付中...' : '立即支付', { type: ButtonType.Normal })
          .width('100%')
          .height(this.s(46))
          .fontSize(this.s(16))
          .fontColor('#FFFFFF')
          .backgroundColor(Colors.brandPrimary)
          .borderRadius(this.s(26))
          .onClick(() => {
            this.onPay();
          });
      } else {
        Text('无需支付，可继续查看订单状态')
          .fontSize(this.s(12))
          .fontColor(Colors.textSecondary)
          .margin({ bottom: this.s(12) });
        Button('完成', { type: ButtonType.Normal })
          .width('100%')
          .height(this.s(46))
          .fontSize(this.s(16))
          .fontColor('#FFFFFF')
          .backgroundColor(Colors.brandPrimary)
          .borderRadius(this.s(26))
          .onClick(() => {
            NavService.go(AppRoute.HOME);
            this.currentRoute = AppRoute.HOME;
          });
      }
    }
    .width('100%');
  }

  build() {
    Column() {
      this.TitleBar();
      Column({ space: this.s(16) }) {
        this.OrderSummaryCard();
        this.ActionArea();
      }
      .width('100%')
      .padding({ left: this.s(16), right: this.s(16), top: this.s(20) });
      Blank().layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topSafeAreaPx })
    .backgroundColor(Colors.pageBackground)
    .onAreaChange((oldValue, newValue) => {
      void oldValue;
      const width = Number(newValue.width);
      if (width > 0) {
        this.pageWidth = width;
      }
    });
  }
}
