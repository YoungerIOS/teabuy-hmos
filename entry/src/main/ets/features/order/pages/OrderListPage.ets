import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { RouteParams } from '../../../router/RouteParams';
import { window } from '@kit.ArkUI';
import { Colors } from '../../../core/ui/theme/Tokens';
import { OrderListData, OrderListItem, OrderRepository, OrderTabSummaryData } from '../data/OrderRepository';

@Component
export struct OrderListPage {
  @Link currentRoute: AppRoute;
  @State private contentWidth: number = 375;
  @State private activeTab: number = 0;
  @State private loading: boolean = false;
  @State private orderData: OrderListData = new OrderListData();
  @State private topSafeAreaPx: number = 0;
  @State private tabSummary: OrderTabSummaryData = new OrderTabSummaryData();
  private scroller: Scroller = new Scroller();

  private s(value: number): number {
    return value * this.contentWidth / 375;
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topSafeAreaPx = px2vp(avoidArea.topRect.height);
    }).catch(() => {
      this.topSafeAreaPx = 44;
    });
    void this.loadTabSummary();
    void this.loadOrders();
  }

  private statusForTab(index: number): string {
    if (index === 0) {
      return 'PENDING_PAYMENT';
    }
    if (index === 1) {
      return 'PAID';
    }
    if (index === 2) {
      return 'SHIPPED';
    }
    return 'COMPLETED';
  }

  private statusLabel(status: string): string {
    if (status === 'PENDING_PAYMENT') {
      return '未支付';
    }
    if (status === 'PAID') {
      return '待发货';
    }
    if (status === 'SHIPPED') {
      return '待收货';
    }
    if (status === 'COMPLETED') {
      return '已完成';
    }
    if (status === 'CANCELLED') {
      return '已取消';
    }
    return status;
  }

  private formatMoney(cent: number): string {
    return `￥${(cent / 100).toFixed(2)}`;
  }

  private formatDate(iso: string): string {
    if (!iso) {
      return '';
    }
    const parts = iso.split('T');
    return parts.length > 0 ? parts[0] : iso;
  }

  private tabItemWidth(): number {
    return (this.contentWidth - this.s(32)) / 4;
  }

  private tabCount(status: string): number {
    for (let i = 0; i < this.tabSummary.items.length; i++) {
      const item = this.tabSummary.items[i];
      if (item.status === status) {
        return item.count;
      }
    }
    return 0;
  }

  private async loadTabSummary(): Promise<void> {
    try {
      this.tabSummary = await OrderRepository.getTabSummary();
    } catch (error) {
      console.error('Failed to load tab summary:', error);
      this.tabSummary = new OrderTabSummaryData();
    }
  }

  private async loadOrders(): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const status = this.statusForTab(this.activeTab);
      this.orderData = await OrderRepository.listOrders(status, 1, 20);
    } catch (error) {
      console.error('Failed to load orders:', error);
      this.orderData = new OrderListData();
    } finally {
      this.loading = false;
    }
  }

  private onTabChange(index: number): void {
    if (this.activeTab === index) {
      return;
    }
    this.activeTab = index;
    void this.loadOrders();
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
      .justifyContent(FlexAlign.Start)
      .padding({ left: this.s(2) })
      .onClick(() => {
        NavService.back();
        this.currentRoute = NavService.getCurrentRoute();
      });

      Text('我的订单')
        .fontSize(this.s(18))
        .fontWeight(FontWeight.Medium)
        .fontColor('#4D716F');

      Blank();
    }
    .width('100%')
    .height(this.s(48))
    .padding({ left: this.s(12), right: this.s(16), top: this.s(8) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Colors.pageBackground);
  }

  @Builder
  private TabBar() {
    Row() {
      this.TabItem(0, '未支付', 'PENDING_PAYMENT');
      this.TabItem(1, '待发货', 'PAID');
      this.TabItem(2, '待收货', 'SHIPPED');
      this.TabItem(3, '已完成', 'COMPLETED');
    }
    .width('100%')
    .padding({ left: this.s(16), right: this.s(16), bottom: this.s(10) })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  private TabItem(index: number, label: string, status: string) {
    Column() {
      Text(label)
        .fontSize(this.s(14))
        .fontColor(this.activeTab === index ? '#4D716F' : '#9AA7A0')
        .fontWeight(this.activeTab === index ? FontWeight.Medium : FontWeight.Regular);
      Text(`${this.tabCount(status)}`)
        .fontSize(this.s(12))
        .fontColor(this.activeTab === index ? '#4D716F' : '#9AA7A0')
        .margin({ top: this.s(2) });
      Row()
        .width(this.s(20))
        .height(this.s(2))
        .backgroundColor(this.activeTab === index ? '#4D716F' : Color.Transparent)
        .margin({ top: this.s(6) });
    }
    .width(this.tabItemWidth())
    .height(this.s(44))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.onTabChange(index));
  }

  @Builder
  private EmptyState() {
    Column() {
      Text('暂无订单')
        .fontSize(this.s(16))
        .fontColor('#9AA7A0')
        .margin({ top: this.s(40) });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private OrderCard(item: OrderListItem) {
    Column() {
      Row() {
        Text(`订单号：${item.orderNo}`)
          .fontSize(this.s(12))
          .fontColor('#7B8B84');
        Blank();
        Text(this.statusLabel(item.status))
          .fontSize(this.s(12))
          .fontColor('#D85E53');
      }
      .width('100%');

      Row() {
        Text(`下单时间：${this.formatDate(item.createdAt)}`)
          .fontSize(this.s(12))
          .fontColor('#9AA7A0');
        Blank();
        Text(`合计 ${this.formatMoney(item.totalCent)}`)
          .fontSize(this.s(14))
          .fontWeight(FontWeight.Medium)
          .fontColor('#4D716F');
      }
      .width('100%')
      .margin({ top: this.s(8) });

      Row() {
        Text('查看详情')
          .fontSize(this.s(12))
          .fontColor('#4D716F')
          .padding({ left: this.s(10), right: this.s(10), top: this.s(4), bottom: this.s(4) })
          .border({ width: 1, color: '#D7E2DD', radius: this.s(12) })
          .onClick(() => {
            const params = new RouteParams();
            params.orderNo = item.orderNo;
            this.currentRoute = AppRoute.PAYMENT_CONFIRM;
            NavService.go(AppRoute.PAYMENT_CONFIRM, params);
          });
        Blank();
        if (item.status === 'PENDING_PAYMENT') {
          Text('去支付')
            .fontSize(this.s(12))
            .fontColor(Color.White)
            .padding({ left: this.s(12), right: this.s(12), top: this.s(4), bottom: this.s(4) })
            .backgroundColor('#4D716F')
            .borderRadius(this.s(12))
            .onClick(() => {
              const params = new RouteParams();
              params.orderNo = item.orderNo;
              this.currentRoute = AppRoute.PAYMENT_CONFIRM;
              NavService.go(AppRoute.PAYMENT_CONFIRM, params);
            });
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.s(12) });
    }
    .width('100%')
    .padding(this.s(14))
    .backgroundColor(Color.White)
    .borderRadius(this.s(8))
    .margin({ top: this.s(12) });
  }

  build() {
    Column() {
      this.TitleBar();
      this.TabBar();

      if (this.loading) {
        Row() {
          Text('加载中...')
            .fontSize(this.s(14))
            .fontColor('#9AA7A0');
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: this.s(24) });
      } else if (this.orderData.items.length === 0) {
        this.EmptyState();
      } else {
        Scroll(this.scroller) {
          Column() {
            ForEach(this.orderData.items, (item: OrderListItem) => {
              this.OrderCard(item);
            }, (item: OrderListItem) => item.orderNo);
          }
          .width('100%')
          .padding({ left: this.s(16), right: this.s(16), bottom: this.s(24) });
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring);
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topSafeAreaPx })
    .backgroundColor(Colors.pageBackground)
    .onAreaChange((oldValue, newValue) => {
      void oldValue;
      const width = Number(newValue.width);
      if (width > 0) {
        this.contentWidth = width;
      }
    });
  }
}
