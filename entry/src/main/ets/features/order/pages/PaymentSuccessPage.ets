import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../../../core/ui/theme/Tokens';
import { window } from '@kit.ArkUI';
import { OrderDetailData, OrderRepository } from '../data/OrderRepository';

class PriceParts {
  symbol: string = '';
  amount: string = '';
  unit: string = '';
}

@Component
export struct PaymentSuccessPage {
  @Link currentRoute: AppRoute;
  @State private pageWidth: number = 375;
  @State private orderNo: string = '';
  @State private totalCent: number = 0;
  @State private status: string = 'PAID';
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
        NavService.go(AppRoute.HOME);
        this.currentRoute = AppRoute.HOME;
      });

      Text('支付成功')
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
  private SummaryCard() {
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
        Text(this.status)
          .fontSize(this.s(12))
          .fontColor(Colors.textPrimary);
      }
      .width('100%')
      .margin({ top: this.s(10) });

      Row() {
        Text('支付金额')
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

  build() {
    Column() {
      this.TitleBar();
      Column({ space: this.s(16) }) {
        this.SummaryCard();
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
